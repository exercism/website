import fs from 'fs/promises'
import path from 'path'

const HAML_EXT = '.html.haml'
const MAX_CHARS = 16000
const TMP_DIR = './tmp/i18n-extraction'
const QUEUE_PATH = path.join(TMP_DIR, 'queue.json')
const DONE_PATH = path.join(TMP_DIR, 'done.json')
const SKIPPED_PATH = path.join(TMP_DIR, 'too-large.json')

export async function readHamlFilesInFolder(
  folder: string
): Promise<Record<string, string>> {
  const result: Record<string, string> = {}

  async function walk(current: string) {
    const entries = await fs.readdir(current, { withFileTypes: true })
    for (const entry of entries) {
      const fullPath = path.join(current, entry.name)
      if (entry.isDirectory()) {
        await walk(fullPath)
      } else if (entry.isFile() && entry.name.endsWith(HAML_EXT)) {
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
      continue
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

    if (resume) {
      queue = await loadJSON(QUEUE_PATH)
      done = await loadJSON(DONE_PATH)
      skipped = await loadJSON(SKIPPED_PATH)
    } else {
      const files = await readHamlFilesInFolder(inputPath!)
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

      // TODO: add runLLM
      done.push(i)
      await persistJSON(DONE_PATH, done)
    }
  })()
}
