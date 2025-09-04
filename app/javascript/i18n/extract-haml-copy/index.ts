import fs from 'fs/promises'
import path from 'path'
import { runLLM } from '../extract-jsx-copy/runLLM'
import { parseLLMOutput } from './parseLLMOutputHaml'
import { buildMailerPrompt } from './buildMailerPromptHaml'

const MAX_CHARS = 5000
const TMP_DIR = './tmp/i18n-extraction'
const QUEUE_PATH = path.join(TMP_DIR, 'queue.json')

const HAML_EXT = '.haml'

async function readHamlFiles(folder: string): Promise<Record<string, string>> {
  const result: Record<string, string> = {}

  async function walk(dir: string) {
    const entries = await fs.readdir(dir, { withFileTypes: true })
    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name)
      if (entry.isDirectory()) {
        await walk(fullPath)
      } else if (entry.isFile() && entry.name.endsWith(HAML_EXT)) {
        const content = await fs.readFile(fullPath, 'utf8')
        if (content.length <= MAX_CHARS) {
          result[fullPath] = content
        } else {
          console.warn(`Skipped oversized file: ${fullPath}`)
        }
      }
    }
  }

  await walk(folder)
  return result
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

async function resetQueue() {
  await fs.rm(TMP_DIR, { recursive: true, force: true })
  console.log('Reset: cleared queue and tmp dir.')
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
      } else {
        throw err
      }
    }
  }
  throw new Error('LLM failed after maximum retries.')
}

async function writeModifiedFiles(files: Record<string, string>) {
  for (const [filePath, content] of Object.entries(files)) {
    await fs.writeFile(filePath, content, 'utf8')
  }
}

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
    if (reset) await resetQueue()

    let queue: Record<string, string>[]
    const debugDir = path.join(TMP_DIR, 'llm-debug')
    await fs.mkdir(debugDir, { recursive: true })

    if (resume) {
      queue = await loadJSON(QUEUE_PATH)
      console.log('Resumed from existing queue.')
    } else {
      const files = await readHamlFiles(inputPath!)
      queue = groupByCharLimit(files, MAX_CHARS)
      await persistJSON(QUEUE_PATH, queue)
      console.log(`Created ${queue.length} batches.`)
    }

    for (let i = 0; i < queue.length; i++) {
      const debugPath = path.join(debugDir, `batch-${i + 1}.txt`)
      try {
        await fs.access(debugPath)
        console.log(`⏭ Batch ${i + 1} already processed.`)
        continue
      } catch {
        // continue to process
      }

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

      const prompt = buildMailerPrompt(batch, inputPath || '.')
      const result = await runLLMWithRetry(prompt)

      await fs.writeFile(debugPath, result, 'utf8')
      const translations = await parseLLMOutput(result)
      console.log('Parsed translations:')
      console.dir(translations, { depth: null })

      // await writeModifiedFiles(batch)
    }

    console.log('\nAll batches completed.')
  })()
}

export function groupByCharLimit(
  files: Record<string, string>,
  maxChars: number
): Record<string, string>[] {
  const batches: Record<string, string>[] = []
  let current: Record<string, string> = {}
  let size = 0

  for (const [filePath, content] of Object.entries(files)) {
    const len = content.length
    if (size + len > maxChars) {
      batches.push(current)
      current = {}
      size = 0
    }

    current[filePath] = content
    size += len
  }

  if (Object.keys(current).length) {
    batches.push(current)
  }

  return batches
}
