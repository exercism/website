import fs from 'node:fs/promises'
import path from 'node:path'
import { execFile } from 'node:child_process'
import { promisify } from 'node:util'
import { buildPrompt } from './buildPrompt'
import { runLLM } from '../extract-jsx-copy/runLLM'
import { createBatches } from './createBatches'

export const execFileAsync = promisify(execFile)

const OUTPUT_DIR = process.env.OUTPUT_DIR || './i18n-batches'

async function writeBatchJson(batchIndex: number, data: any[]) {
  await fs.mkdir(OUTPUT_DIR, { recursive: true })
  const fileName = `batch-${String(batchIndex + 1).padStart(3, '0')}.json`
  const outPath = path.join(OUTPUT_DIR, fileName)
  await fs.writeFile(outPath, JSON.stringify(data, null, 2), 'utf8')
  return outPath
}

;(async () => {
  const inputDir = process.argv[2] || './input'
  const commitSha =
    process.argv[3] || 'ccaebe4d435f235be6e624b72e9a4e1c841c7520'
  const batches = await createBatches(inputDir, commitSha)

  for (let i = 0; i < batches.length; i++) {
    console.log('started batch', i + 1, 'of', batches.length)

    const batch = batches[i]
    const prompt = buildPrompt(batch.content)
    const arr = await runLLM(prompt)

    if (arr) {
      const outPath = await writeBatchJson(i, arr)
      console.log(`Wrote ${arr.length} entries → ${outPath}`)
    } else {
      console.log(`No results from batch ${i + 1}`)
    }
  }

  console.log('Done.')
})()
