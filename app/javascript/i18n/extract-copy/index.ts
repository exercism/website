// extract-and-prepare.ts
import fs from 'fs/promises'
import path from 'path'
import { normalizePathForNamespace } from './normalizePathForNamespace'
import { buildPrompt } from './buildPrompt'
import { runLLM } from './runLLM'

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
  const content = `export default ${jsonString};\n`
  await fs.writeFile(filePath, content, 'utf8')
}

async function writeModifiedFiles(files: Record<string, string>) {
  for (const [filePath, content] of Object.entries(files)) {
    await fs.writeFile(filePath, content, 'utf8')
  }
}

// CLI Entrypoint
if (require.main === module) {
  const folder = process.argv[2]

  if (!folder) {
    console.error('Please provide a folder path.')
    process.exit(1)
  }

  readFilesInFolder(folder)
    .then(async (files) => {
      const prompt = buildPrompt(files, folder)
      const result = await runLLM(prompt)
      if (!result) {
        throw new Error('LLM returned no response')
      }
      await writeRawLLMOutput(result, folder)
      const parsed = parseLLMOutput(result)
      await writeTranslations(parsed.translations, folder)
      await writeModifiedFiles(parsed.files)
      console.log('i18n extraction and rewrite complete.')
      console.log(`Translation namespace: ${normalizePathForNamespace(folder)}`)
    })
    .catch((err) => {
      console.error('Error:', err)
      process.exit(1)
    })
}
