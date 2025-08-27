import fs from 'node:fs/promises'
import path from 'node:path'
import { execFile } from 'node:child_process'
import { promisify } from 'node:util'

const execFileAsync = promisify(execFile)
const OUTPUT_FILE = './i18n-results.ndjson'

async function getFileAtCommit(
  absPath: string,
  commit: string
): Promise<string | null> {
  try {
    let dir = path.dirname(absPath)
    let root: string | null = null

    while (dir !== path.dirname(dir)) {
      try {
        await fs.stat(path.join(dir, '.git'))
        root = dir
        break
      } catch {
        dir = path.dirname(dir)
      }
    }

    if (!root) return null

    const relPath = path.relative(root, absPath)
    const gitPath = relPath.split(path.sep).join('/')

    const { stdout } = await execFileAsync(
      'git',
      ['show', `${commit}:${gitPath}`],
      {
        cwd: root,
        maxBuffer: 10 * 1024 * 1024,
      }
    )

    return stdout
  } catch (err) {
    console.error(`git show failed for ${absPath}:`, err)
    return null
  }
}

async function* walk(dir: string): AsyncGenerator<string> {
  for (const entry of await fs.readdir(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name)
    if (entry.isDirectory()) {
      yield* walk(fullPath)
    } else {
      yield fullPath
    }
  }
}

async function createBatches(dir: string, commit: string, maxChars = 10_000) {
  const batches: { files: string[]; content: string }[] = []
  let currentFiles: string[] = []
  let currentContent = ''

  for await (const filePath of walk(dir)) {
    const newContent = await fs.readFile(filePath, 'utf8')
    const oldContent = await getFileAtCommit(filePath, commit)

    const combined = `
--- ${filePath} (OLD @ ${commit}) ---
${oldContent ?? '[not found in commit]'}
--- ${filePath} (NEW @ working tree) ---
${newContent}
`

    if (
      currentContent.length + combined.length > maxChars &&
      currentContent.length > 0
    ) {
      batches.push({ files: [...currentFiles], content: currentContent })
      currentFiles = []
      currentContent = ''
    }

    currentFiles.push(filePath)
    currentContent += combined
  }

  if (currentFiles.length > 0) {
    batches.push({ files: currentFiles, content: currentContent })
  }

  return batches
}

async function fakeRunLLM(batch: { files: string[]; content: string }) {
  return batch.files.map((f, i) => ({
    key: path.basename(f) + '_' + i,
    desc: `Fake description for ${path.basename(f)}`,
  }))
}

async function appendResults(results: { key: string; desc: string }[]) {
  const lines = results.map((r) => JSON.stringify(r)).join('\n') + '\n'
  await fs.appendFile(OUTPUT_FILE, lines, 'utf8')
}

;(async () => {
  const inputDir = process.argv[2] || './input'
  const commitSha = process.argv[3] || 'HEAD~1'

  const batches = await createBatches(inputDir, commitSha)

  for (let idx = 0; idx < batches.length; idx++) {
    const batch = batches[idx]
    console.log(`Processing batch ${idx + 1} (${batch.files.length} files)`)
    console.log(batch.content.slice(0, 500) + '\n...')

    const fakeResults = await fakeRunLLM(batch)
    await appendResults(fakeResults)

    console.log(`→ Appended ${fakeResults.length} results to ${OUTPUT_FILE}`)
  }
})()
