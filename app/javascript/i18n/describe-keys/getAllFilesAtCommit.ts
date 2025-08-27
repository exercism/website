import path from 'path'
import { execFileAsync } from '.'

export async function findGitRoot(startDir: string): Promise<string | null> {
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
