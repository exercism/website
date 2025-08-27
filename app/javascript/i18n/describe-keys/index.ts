import fs from 'node:fs/promises'
import path from 'node:path'
import { execFile } from 'node:child_process'
import { promisify } from 'node:util'

const execFileAsync = promisify(execFile)
let ROOT_CACHE: string | null = null

async function findGitRoot(startDir: string): Promise<string | null> {
  try {
    const { stdout } = await execFileAsync('git', [
      '-C',
      startDir,
      'rev-parse',
      '--show-toplevel',
    ])
    return stdout.trim()
  } catch {
    return null
  }
}

function pLimit(n: number) {
  let active = 0
  const q: (() => void)[] = []
  const next = () => {
    active--
    q.shift()?.()
  }
  return <T>(fn: () => Promise<T>) =>
    new Promise<T>((res, rej) => {
      const run = () =>
        fn().then(
          (v) => {
            res(v)
            next()
          },
          (e) => {
            rej(e)
            next()
          }
        )
      active < n ? run() : q.push(run)
    })
}

export async function getAllFilesAtCommit(
  filePaths: string[],
  commit: string,
  root: string,
  concurrency = 16
): Promise<Map<string, string | null>> {
  const results = new Map<string, string | null>()
  const limit = pLimit(concurrency)

  await Promise.all(
    filePaths.map((abs) =>
      limit(async () => {
        const rel = path.relative(root, abs).split(path.sep).join('/')
        try {
          const { stdout } = await execFileAsync(
            'git',
            ['-C', root, 'show', `${commit}:${rel}`],
            {
              maxBuffer: 20 * 1024 * 1024,
              env: { ...process.env, GIT_LFS_SKIP_SMUDGE: '1' },
            }
          )
          results.set(abs, stdout.toString())
        } catch {
          results.set(abs, null)
        }
      })
    )
  )

  return results
}

async function* walk(dir: string): AsyncGenerator<string> {
  for (const e of await fs.readdir(dir, { withFileTypes: true })) {
    const full = path.join(dir, e.name)
    if (e.isDirectory()) yield* walk(full)
    else yield full
  }
}

async function createBatches(dir: string, commit: string, maxChars = 10_000) {
  const allFiles: string[] = []
  for await (const f of walk(dir)) allFiles.push(f)

  const startDir = path.dirname(path.resolve(allFiles[0] || dir))
  const root = ROOT_CACHE ?? (ROOT_CACHE = await findGitRoot(startDir))
  if (!root) return []

  const oldContentMap = await getAllFilesAtCommit(allFiles, commit, root)

  const batches: { files: string[]; content: string }[] = []
  let curFiles: string[] = []
  let curContent = ''

  for (const file of allFiles) {
    const newContent = await fs.readFile(file, 'utf8')
    const oldContent = oldContentMap.get(file)
    const combined = `\n--- ${file} (OLD @ ${commit}) ---\n${
      oldContent ?? '[not found]'
    }\n--- ${file} (NEW) ---\n${newContent}\n`

    if (
      curContent.length + combined.length > maxChars &&
      curContent.length > 0
    ) {
      batches.push({ files: [...curFiles], content: curContent })
      curFiles = []
      curContent = ''
    }
    curFiles.push(file)
    curContent += combined
  }

  if (curFiles.length > 0) {
    batches.push({ files: curFiles, content: curContent })
  }

  return batches
}

// main
;(async () => {
  const inputDir = process.argv[2] || './input'
  const commitSha =
    process.argv[3] || 'ccaebe4d435f235be6e624b72e9a4e1c841c7520'
  const batches = await createBatches(inputDir, commitSha)
  for (let i = 0; i < batches.length; i++) {
    if (i === 0) {
      console.log(`Batch ${i + 1}: ${batches[i].files.length} files`)
      console.log(batches[i].content)
    }
  }
})()
