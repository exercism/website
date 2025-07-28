import fs from 'fs/promises'
import path from 'path'
import { runLLM } from '../extract-jsx-copy/runLLM'
import { buildPrompt } from './buildPromptHaml'
import { parseLLMOutputHaml } from './parseLLMOutputHaml'
import { toCamelCase } from '../extract-jsx-copy/toCamelCase'
import { normalizePathForNamespace } from '../extract-jsx-copy/normalizePathForNamespace'

const HAML_EXT = '.html.haml'
const MAX_CHARS = 16000
const TMP_DIR = './tmp/i18n-extraction'
const OUTPUT_DIR = './en-yaml'
const QUEUE_PATH = path.join(TMP_DIR, 'queue.json')
const DONE_PATH = path.join(TMP_DIR, 'done.json')
const SKIPPED_PATH = path.join(TMP_DIR, 'too-large.json')
const PROCESSED_PATH = path.join(TMP_DIR, 'processed.json')

export async function readHamlFilesInFolder(
  folder: string,
  processedPaths: Set<string>
): Promise<Record<string, string>> {
  const result: Record<string, string> = {}

  async function walk(current: string) {
    const entries = await fs.readdir(current, { withFileTypes: true })
    for (const entry of entries) {
      const fullPath = path.join(current, entry.name)
      if (entry.isDirectory()) {
        await walk(fullPath)
      } else if (
        entry.isFile() &&
        entry.name.endsWith(HAML_EXT) &&
        !processedPaths.has(fullPath)
      ) {
        const content = await fs.readFile(fullPath, 'utf8')
        result[fullPath] = content
      }
    }
  }

  await walk(folder)
  return result
}

export function groupByCharLimit(
  files: Record<string, string>,
  maxChars: number = MAX_CHARS
): Record<string, string>[] {
  const batches: Record<string, string>[] = []
  let currentBatch: Record<string, string> = {}
  let currentSize = 0

  for (const [filePath, content] of Object.entries(files)) {
    const contentLength = content.length

    if (contentLength > maxChars) {
      continue // will be handled elsewhere
    }

    if (currentSize + contentLength > maxChars) {
      batches.push(currentBatch)
      currentBatch = {}
      currentSize = 0
    }

    currentBatch[filePath] = content
    currentSize += contentLength
  }

  if (Object.keys(currentBatch).length > 0) {
    batches.push(currentBatch)
  }

  return batches
}

function escapeRegex(text: string): string {
  return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

function extractInterpolationVars(text: string): string {
  // Extract variables from %{var_name} format and convert to hash syntax
  const matches = text.match(/%\{(\w+)\}/g)
  if (!matches) return ''

  const vars = matches.map((match) => {
    const varName = match.slice(2, -1) // Remove %{ and }
    // Convert snake_case to the most likely Ruby variable
    return `${varName}: ${varName.replace(/_/g, '.')}`
  })

  return vars.join(', ')
}

function replaceStringsWithI18nKeys(
  hamlContent: string,
  translations: Record<string, string>,
  keyPrefix: string
): string {
  let modifiedContent = hamlContent

  const valueToKey: Record<string, string> = {}
  for (const [key, value] of Object.entries(translations)) {
    if (key.startsWith(keyPrefix)) {
      valueToKey[value] = key
    }
  }

  const sortedEntries = Object.entries(valueToKey).sort(
    (a, b) => b[0].length - a[0].length
  )

  for (const [originalText, i18nKey] of sortedEntries) {
    // Skip if already processed (contains t('...'))
    if (originalText.includes("t('")) continue

    const hasInterpolation = originalText.includes('%{')
    const tCall = hasInterpolation
      ? `t('${i18nKey}', ${extractInterpolationVars(originalText)})`
      : `t('${i18nKey}')`

    // Handle different HAML patterns
    const patterns = [
      // Quoted strings in content_for
      {
        regex: new RegExp(
          `(\\s*-\\s*content_for\\s+[^,]+,\\s*)["']${escapeRegex(
            originalText
          )}["']`,
          'g'
        ),
        replacement: `$1${tCall}`,
      },
      // Quoted strings after =
      {
        regex: new RegExp(`(=\\s*)["']${escapeRegex(originalText)}["']`, 'g'),
        replacement: `$1${tCall}`,
      },
      // Text after HAML tags (like %h1 Some text)
      {
        regex: new RegExp(
          `^(\\s*%\\w+(?:\\.[\\w.-]+)*(?:\\{[^}]*\\})?\\s+)${escapeRegex(
            originalText
          )}$`,
          'gm'
        ),
        replacement: `$1= ${tCall}`,
      },
      // Text after class/id selectors (like .title Some text)
      {
        regex: new RegExp(
          `^(\\s*[.#][\\w.-]+\\s+)${escapeRegex(originalText)}$`,
          'gm'
        ),
        replacement: `$1= ${tCall}`,
      },
      // Link text: link_to "text", path
      {
        regex: new RegExp(
          `(link_to\\s+)["']${escapeRegex(originalText)}["']`,
          'g'
        ),
        replacement: `$1${tCall}`,
      },
      // Quoted strings in attributes like placeholder: "text"
      {
        regex: new RegExp(
          `(\\w+:\\s*)["']${escapeRegex(originalText)}["']`,
          'g'
        ),
        replacement: `$1${tCall}`,
      },
      // Plain quoted strings (fallback)
      {
        regex: new RegExp(`["']${escapeRegex(originalText)}["']`, 'g'),
        replacement: tCall,
      },
    ]

    for (const pattern of patterns) {
      const newContent = modifiedContent.replace(
        pattern.regex,
        pattern.replacement
      )
      if (newContent !== modifiedContent) {
        modifiedContent = newContent
        break // Only apply first matching pattern
      }
    }
  }

  // Clean up any double equals (= = t('...') -> = t('...'))
  modifiedContent = modifiedContent.replace(/=\s*=\s*t\(/g, '= t(')

  return modifiedContent
}

async function persistJSON(filePath: string, data: any) {
  await fs.mkdir(path.dirname(filePath), { recursive: true })
  await fs.writeFile(filePath, JSON.stringify(data, null, 2), 'utf8')
}

async function loadJSON<T>(filePath: string): Promise<T> {
  try {
    const raw = await fs.readFile(filePath, 'utf8')
    return JSON.parse(raw)
  } catch {
    return [] as unknown as T
  }
}

async function resetAllQueues() {
  await fs.rm(TMP_DIR, { recursive: true, force: true })
}

async function runLLMWithRetry(prompt: string, retries = 3): Promise<string> {
  for (let i = 0; i < retries; i++) {
    try {
      const result = await runLLM(prompt)
      if (result) return result
    } catch (err: any) {
      if (err.message?.includes('503') || err.message?.includes('overloaded')) {
        console.warn(`Gemini overloaded. Retry ${i + 1}/${retries}...`)
        await new Promise((res) => setTimeout(res, 2000 * (i + 1)))
        continue
      }
      throw err
    }
  }
  throw new Error('LLM failed after maximum retries.')
}

function getLocalesOutputPath(inputPath: string): string {
  const absInput = path.resolve(inputPath)
  const absRoot = path.resolve('../../views')
  if (!absInput.startsWith(absRoot)) {
    throw new Error('Input path must be under ../../views')
  }
  const relative = path.relative(absRoot, absInput)
  return path.join('config/locales/views', relative)
}

async function writeTranslationJson(
  translations: Record<string, string>,
  inputPath: string,
  namespace: string
) {
  const folderPath = getLocalesOutputPath(inputPath)
  const outputPath = path.join(folderPath, `${namespace}.json`)
  await fs.mkdir(path.dirname(outputPath), { recursive: true })
  await fs.writeFile(outputPath, JSON.stringify(translations, null, 2), 'utf8')
}

async function writeModifiedFiles(files: Record<string, string>) {
  for (const [filePath, content] of Object.entries(files)) {
    await fs.writeFile(filePath, content, 'utf8')
  }
}

// CLI runner
if (require.main === module) {
  const args = process.argv.slice(2)
  const inputPath = args.find((a) => !a.startsWith('--'))
  const resume = args.includes('--resume')
  const reset = args.includes('--reset')

  if (!inputPath && !resume) {
    console.error('Please provide a folder path or use --resume.')
    process.exit(1)
  }

  ;(async () => {
    if (reset) {
      await resetAllQueues()
      console.log('Cleared previous queue state.')
    }

    let queue: Record<string, string>[] = []
    let done: number[] = []
    let skipped: string[] = []
    let processedPaths: string[] = []

    if (resume) {
      queue = await loadJSON(QUEUE_PATH)
      done = await loadJSON(DONE_PATH)
      skipped = await loadJSON(SKIPPED_PATH)
      processedPaths = await loadJSON(PROCESSED_PATH)
    } else {
      processedPaths = await loadJSON(PROCESSED_PATH)
      const processedSet = new Set(processedPaths)
      const files = await readHamlFilesInFolder(inputPath!, processedSet)

      skipped = Object.entries(files)
        .filter(([_, content]) => content.length > MAX_CHARS)
        .map(([path]) => path)

      queue = groupByCharLimit(files)
      done = []

      await persistJSON(QUEUE_PATH, queue)
      await persistJSON(DONE_PATH, done)
      await persistJSON(SKIPPED_PATH, skipped)
    }

    console.log(
      `Queue has ${queue.length} batches. ${done.length} already completed.`
    )
    if (skipped.length)
      console.log(`${skipped.length} files too large and skipped.`)

    const namespace = normalizePathForNamespace(inputPath || '.')

    for (let i = 0; i < queue.length; i++) {
      if (done.includes(i)) continue

      const batch = queue[i]
      const totalChars = Object.values(batch).reduce(
        (sum, v) => sum + v.length,
        0
      )
      console.log(
        `\nBatch ${i + 1}/${queue.length} (${
          Object.keys(batch).length
        } files, ${totalChars} chars)`
      )

      const prompt = buildPrompt(batch, inputPath || '.')
      const result = await runLLMWithRetry(prompt)
      console.log('\n🔍 Raw LLM output:\n', result.slice(0, 500) + '...')

      const translations = parseLLMOutputHaml(result)
      console.log('\n🧪 Parsed translations:')
      console.dir(translations, { depth: null })

      // Write the translations JSON
      await writeTranslationJson(translations, inputPath || '.', namespace)

      // Modify the HAML files to use i18n keys
      const modifiedFiles: Record<string, string> = {}
      for (const [filePath, originalContent] of Object.entries(batch)) {
        const relativePath = path.relative(inputPath || '.', filePath)
        const withoutExt = relativePath.replace(/\.html\.haml$/, '')
        const parts = withoutExt.split(path.sep)
        const camelParts = parts.map(toCamelCase)
        const keyPrefix = camelParts.join('.')

        const modifiedContent = replaceStringsWithI18nKeys(
          originalContent,
          translations,
          keyPrefix
        )
        modifiedFiles[filePath] = modifiedContent
      }

      await writeModifiedFiles(modifiedFiles)

      // Track completed batch
      done.push(i)
      await persistJSON(DONE_PATH, done)

      // Track processed files globally
      const existing = await loadJSON<string[]>(PROCESSED_PATH)
      const updated = [...new Set([...existing, ...Object.keys(modifiedFiles)])]
      await persistJSON(PROCESSED_PATH, updated)
    }
  })()
}
