// extract-and-prepare.ts
import fs from 'fs/promises'
import path from 'path'
import { normalizePathForNamespace } from './normalizePathForNamespace'
import { buildPrompt } from './buildPrompt'
import { runLLM } from './runLLM'
import { generateEnIndex } from '../generateIndexFile'

const supportedExtensions = ['.tsx', '.jsx']

export async function readFilesInFolder(
  folder: string
): Promise<Record<string, string>> {
  const result: Record<string, string> = {}

  async function readRecursive(currentFolder: string) {
    const entries = await fs.readdir(currentFolder, { withFileTypes: true })

    for (const entry of entries) {
      const fullPath = path.join(currentFolder, entry.name)

      if (entry.isDirectory()) {
        await readRecursive(fullPath)
      } else if (supportedExtensions.includes(path.extname(entry.name))) {
        const content = await fs.readFile(fullPath, 'utf8')
        result[fullPath] = content
      }
    }
  }

  await readRecursive(folder)
  return result
}

function parseLLMOutput(text: string): {
  translations: string
  files: Record<string, string>
} {
  // More flexible regex to capture the i18n export
  const i18nMatch = text.match(
    /\/\/ i18n[\s\S]*?export default\s*({[\s\S]*?})\s*(?:\/\/ modified_files|$)/
  )

  let translations = i18nMatch?.[1]?.trim() || '{}'

  // Clean up any trailing content after the closing brace
  const braceCount =
    (translations.match(/{/g) || []).length -
    (translations.match(/}/g) || []).length
  if (braceCount !== 0) {
    // Find the proper closing brace
    let openBraces = 0
    let endIndex = -1
    for (let i = 0; i < translations.length; i++) {
      if (translations[i] === '{') openBraces++
      if (translations[i] === '}') {
        openBraces--
        if (openBraces === 0) {
          endIndex = i
          break
        }
      }
    }
    if (endIndex !== -1) {
      translations = translations.substring(0, endIndex + 1)
    }
  }

  const fileSections = text.split(/\/\/ === file: (.*?) ===/g).slice(1)
  const files: Record<string, string> = {}

  for (let i = 0; i < fileSections.length; i += 2) {
    const filePath = fileSections[i]?.trim()
    const content = fileSections[i + 1]?.split('// === end file ===')[0]?.trim()
    if (filePath && content) {
      files[filePath] = content
    } else {
      console.warn(`Could not parse file section at index ${i}`)
    }
  }

  if (Object.keys(files).length === 0) {
    console.warn('No modified files were parsed from Gemini output.')
  }

  return {
    translations,
    files,
  }
}

async function writeRawLLMOutput(content: string, folder: string) {
  const normalizedPath = normalizePathForNamespace(folder)
  const safeName = normalizedPath.replace(/[\/\\]/g, '-')
  const outputDir = path.join('./en/debug')
  const filePath = path.join(outputDir, `${safeName}-llm-output.txt`)

  await fs.mkdir(outputDir, { recursive: true })
  await fs.writeFile(filePath, content, 'utf8')
}

async function writeTranslations(jsonString: string, folder: string) {
  const normalizedPath = normalizePathForNamespace(folder)
  const safeName = normalizedPath.replace(/[\/\\]/g, '-')
  const outputDir = path.join('./en')
  const filePath = path.join(outputDir, `${safeName}.ts`)

  await fs.mkdir(outputDir, { recursive: true })
  const content = `// namespace: ${normalizedPath}\nexport default ${jsonString};\n`
  await fs.writeFile(filePath, content, 'utf8')
}

async function writeModifiedFiles(files: Record<string, string>) {
  for (const [filePath, content] of Object.entries(files)) {
    await fs.writeFile(filePath, content, 'utf8')
  }
}

// extract-and-prepare.ts (changes only below the helper functions)

async function readFilesInFolderNonRecursive(
  folder: string
): Promise<Record<string, string>> {
  const result: Record<string, string> = {}
  const entries = await fs.readdir(folder, { withFileTypes: true })

  for (const entry of entries) {
    if (
      entry.isFile() &&
      supportedExtensions.includes(path.extname(entry.name))
    ) {
      const fullPath = path.join(folder, entry.name)
      const content = await fs.readFile(fullPath, 'utf8')
      result[fullPath] = content
    }
  }

  return result
}

async function readSingleFile(
  filePath: string
): Promise<Record<string, string>> {
  if (!supportedExtensions.includes(path.extname(filePath))) {
    throw new Error(`Unsupported file type: ${filePath}`)
  }
  const content = await fs.readFile(filePath, 'utf8')
  return { [filePath]: content }
}

// CLI Entrypoint
// # Non-recursive (default if no flag is passed)
// bun ./extract-copy/index.ts path/to/folder

// # Recursive
// bun ./extract-copy/index.ts path/to/folder --recursive

// # Single file
// bun ./extract-copy/index.ts path/to/file.tsx --single

// # Batch mode
// bun ./extract-copy/index.ts --batch ./a/file1.tsx ./a/file2.tsx ./b/file3.tsx

if (require.main === module) {
  const args = process.argv.slice(2)
  const paths = args.filter((arg) => !arg.startsWith('--'))
  const folderOrFile = paths[0]
  const isRecursive = args.includes('--recursive')
  const isSingleFile = args.includes('--single')
  const isBatchMode = args.includes('--batch')

  if (!folderOrFile && !isBatchMode) {
    console.error('Please provide a file or folder path.')
    process.exit(1)
  }

  if (isBatchMode) {
    console.log('BATCH MODE')
    if (paths.length === 0) {
      console.error('Please provide one or more file paths for batch mode.')
      process.exit(1)
    }

    // Group files by their parent folder name
    const batches: Record<string, string[]> = {}
    for (const filePath of paths) {
      const parentDir = path.basename(path.dirname(filePath))
      if (!supportedExtensions.includes(path.extname(filePath))) continue
      if (!batches[parentDir]) batches[parentDir] = []
      batches[parentDir].push(filePath)
    }

    void (async () => {
      for (const [parentDir, files] of Object.entries(batches)) {
        const fileContents: Record<string, string> = {}
        for (const file of files) {
          fileContents[file] = await fs.readFile(file, 'utf8')
        }

        const prompt = buildPrompt(fileContents, parentDir)
        const result = await runLLM(prompt)
        if (!result)
          throw new Error(`LLM returned no response for batch ${parentDir}`)

        await writeRawLLMOutput(result, parentDir + '-batch')
        const parsed = parseLLMOutput(result)
        await writeTranslations(parsed.translations, parentDir + '-batch')
        await writeModifiedFiles(parsed.files)

        console.log(
          `Batch "${parentDir}" complete. Output in en/${parentDir}-batch.ts`
        )
      }

      await generateEnIndex()
    })().catch((err) => {
      console.error('Batch processing error:', err)
      process.exit(1)
    })
  } else {
    let readFilesPromise: Promise<Record<string, string>>

    if (isSingleFile) {
      readFilesPromise = readSingleFile(folderOrFile)
    } else if (isRecursive) {
      readFilesPromise = readFilesInFolder(folderOrFile)
    } else {
      readFilesPromise = readFilesInFolderNonRecursive(folderOrFile)
    }

    readFilesPromise
      .then(async (files) => {
        const prompt = buildPrompt(files, folderOrFile)
        const result = await runLLM(prompt)
        if (!result) throw new Error('LLM returned no response')

        await writeRawLLMOutput(result, folderOrFile)
        const parsed = parseLLMOutput(result)
        await writeTranslations(parsed.translations, folderOrFile)
        await writeModifiedFiles(parsed.files)

        generateEnIndex().catch((err) => {
          console.error('Failed to generate en/index.ts:', err)
          process.exit(1)
        })

        console.log('i18n extraction and rewrite complete.')
        console.log(
          `Translation namespace: ${normalizePathForNamespace(folderOrFile)}`
        )
      })
      .catch((err) => {
        console.error('Error:', err)
        process.exit(1)
      })
  }
}
