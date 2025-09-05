import fs from 'node:fs/promises'
import path from 'path'
import { findGitRoot, getAllFilesAtCommit } from './getAllFilesAtCommit'
import { walk } from './walk'

const MAX_CHARS = 10_000
let ROOT_CACHE: string | null = null

export async function createBatches(
  dir: string,
  commit: string,
  maxChars = MAX_CHARS
) {
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
