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

async function writeBatchJson(batchIndex: number, data: unknown) {
  await fs.mkdir(OUTPUT_DIR, { recursive: true })
  const fileName = `batch-${String(batchIndex + 1).padStart(3, '0')}.json`
  const outPath = path.join(OUTPUT_DIR, fileName)
  await fs.writeFile(outPath, JSON.stringify(data, null, 2), 'utf8')
  return outPath
}

// --- helpers -------------------------------------------------------------

function getStartFromArg(argv: string[]): number | null {
  // priority: env START_FROM > --start=N > positional arg #4
  const fromEnv = process.env.START_FROM
  if (fromEnv && /^\d+$/.test(fromEnv)) return Number(fromEnv)

  const flag = argv.find((a) => a.startsWith('--start='))
  if (flag) {
    const n = flag.split('=')[1]
    if (/^\d+$/.test(n)) return Number(n)
  }

  const pos = argv[4]
  if (pos && /^\d+$/.test(pos)) return Number(pos)

  return null
}

;(async () => {
  const inputDir = process.argv[2] || './input'
  const commitSha =
    process.argv[3] || 'ccaebe4d435f235be6e624b72e9a4e1c841c7520'
  const batches = await createBatches(inputDir, commitSha)

  const startFromCli = getStartFromArg(process.argv)
  const startFrom = 10
  const startIndex = Math.min(batches.length, startFrom) - 1

  console.log(
    `Total batches: ${batches.length}. Starting from batch ${startFrom} (index ${startIndex}).`
  )

  for (let i = startIndex; i < batches.length; i++) {
    console.log('started batch', i + 1, 'of', batches.length)

    const batch = batches[i]
    const prompt = buildPrompt(batch.content)
    const llmOutput = await runLLM(prompt)

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
