import fs from 'node:fs/promises'
import path from 'node:path'
import { execFile } from 'node:child_process'
import { promisify } from 'node:util'
import { buildPrompt } from './buildPrompt'
import { runLLM } from '../extract-jsx-copy/runLLM'
import { createBatches } from './createBatches'
import { parseLLMOutput } from './parseLLMOutput'

export const execFileAsync = promisify(execFile)

const OUTPUT_DIR = process.env.OUTPUT_DIR || './i18n-descriptions'
const DEBUG_DIR = process.env.DEBUG_DIR || './i18n-debug'

const DEFAULT_COMMIT_SHA = 'ccaebe4d435f235be6e624b72e9a4e1c841c7520'

async function writeBatchJson(batchIndex: number, data: unknown) {
  await fs.mkdir(OUTPUT_DIR, { recursive: true })
  const fileName = `batch-${String(batchIndex + 1).padStart(3, '0')}.json`
  const outPath = path.join(OUTPUT_DIR, fileName)
  await fs.writeFile(outPath, JSON.stringify(data, null, 2), 'utf8')
  return outPath
}

async function writeDebugFile(
  batchIndex: number,
  kind: string,
  content: string
) {
  await fs.mkdir(DEBUG_DIR, { recursive: true })
  const fileName = `batch-${String(batchIndex + 1).padStart(3, '0')}.${kind}`
  const outPath = path.join(DEBUG_DIR, fileName)
  await fs.writeFile(outPath, content, 'utf8')
  return outPath
}

;(async () => {
  const inputDir = process.argv[2] || './input'

  const startFromRaw = process.argv[3]
  const startFrom =
    startFromRaw && /^\d+$/.test(startFromRaw) ? Number(startFromRaw) : 1

  const commitSha =
    process.argv[4] || process.env.COMMIT_SHA || DEFAULT_COMMIT_SHA

  const batches = await createBatches(inputDir, commitSha)

  const startIndex = Math.min(batches.length, Math.max(1, startFrom)) - 1

  console.log(
    `Total batches: ${batches.length}. Starting from batch ${startFrom} (index ${startIndex}).`
  )

  for (let i = startIndex; i < batches.length; i++) {
    console.log('started batch', i + 1, 'of', batches.length)

    const batch = batches[i]

    await writeDebugFile(i, 'batch.txt', batch.content ?? '(no batch content)')

    const prompt = buildPrompt(batch.content)

    if (prompt.includes('${batchContent}')) {
      throw new Error(
        'Prompt still contains a literal ${batchContent}. Check buildPrompt interpolation.'
      )
    }

    await writeDebugFile(i, 'prompt.txt', prompt)

    const llmOutput = await runLLM(prompt)
    await writeDebugFile(i, 'output.raw.txt', llmOutput ?? '(undefined)')

    const parsedOutput = llmOutput ? parseLLMOutput(llmOutput) : null

    if (parsedOutput) {
      const outPath = await writeBatchJson(i, parsedOutput as any)

      const count = Array.isArray(parsedOutput)
        ? parsedOutput.length
        : Object.keys(parsedOutput as Record<string, unknown>).length

      console.log(
        `Wrote ${count} entr${count === 1 ? 'y' : 'ies'} → ${outPath}`
      )
    } else {
      console.log(`No results from batch ${i + 1}`)
    }
  }

  console.log('Done.')
})()
