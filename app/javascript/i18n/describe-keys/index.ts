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

/**
 * Extract EXACT t('...') / t("...") keys from ONLY NEW sections of the batch content.
 * Assumes the batch uses markers "OLD:" and "NEW:" to delineate sections.
 * If your markers are different, adjust the toggling logic below.
 */
function extractKeysFromNewSections(batchContent: string): string[] {
  const lines = batchContent.split('\n')
  let inNew = false
  const keys = new Set<string>()
  const tCallRe = /(?:^|[^\w])t\(\s*(['"])(.*?)\1\s*[,)]/g

  for (const rawLine of lines) {
    const line = rawLine.trim()

    // Toggle based on simple markers
    if (/^NEW\s*:?\s*$/i.test(line) || /^###\s*NEW\b/i.test(line)) {
      inNew = true
      continue
    }
    if (/^OLD\s*:?\s*$/i.test(line) || /^###\s*OLD\b/i.test(line)) {
      inNew = false
      continue
    }

    if (!inNew) continue

    // Find all t('...') in this line
    let m: RegExpExecArray | null
    tCallRe.lastIndex = 0
    while ((m = tCallRe.exec(line))) {
      const key = m[2]
      if (key) keys.add(key)
    }
  }

  return Array.from(keys)
}

/**
 * Build a short report comparing expected keys (from NEW sections) vs returned keys from LLM output.
 */
function buildKeyReport(expectedKeys: string[], returned: unknown): string {
  const returnedKeys = new Set<string>(
    returned && !Array.isArray(returned) && typeof returned === 'object'
      ? Object.keys(returned as Record<string, unknown>)
      : []
  )

  const expectedSet = new Set(expectedKeys)
  const missing = expectedKeys.filter((k) => !returnedKeys.has(k))
  const unexpected = Array.from(returnedKeys).filter((k) => !expectedSet.has(k))
  const intersect = expectedKeys.filter((k) => returnedKeys.has(k))

  const lines: string[] = []
  lines.push(`Expected keys (from NEW t(...)): ${expectedKeys.length}`)
  for (const k of expectedKeys) lines.push(`  • ${k}`)

  lines.push('')
  lines.push(`Returned keys: ${returnedKeys.size}`)
  for (const k of returnedKeys) lines.push(`  • ${k}`)

  lines.push('')
  lines.push(`Matched keys: ${intersect.length}`)
  for (const k of intersect) lines.push(`  ✓ ${k}`)

  lines.push('')
  lines.push(`Missing (expected but not returned): ${missing.length}`)
  for (const k of missing) lines.push(`  - ${k}`)

  lines.push('')
  lines.push(`Unexpected (returned but not expected): ${unexpected.length}`)
  for (const k of unexpected) lines.push(`  ! ${k}`)

  return lines.join('\n')
}

// --- startFrom helper (kept, optional) -----------------------------------
function getStartFromArg(argv: string[]): number | null {
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

// --- main ----------------------------------------------------------------
;(async () => {
  const inputDir = process.argv[2] || './input'
  const commitSha =
    process.argv[3] || 'ccaebe4d435f235be6e624b72e9a4e1c841c7520'
  const batches = await createBatches(inputDir, commitSha)

  const startFromCli = getStartFromArg(process.argv)
  const startFrom = Math.max(1, startFromCli ?? 1)
  const startIndex = Math.min(batches.length, startFrom) - 1

  console.log(
    `Total batches: ${batches.length}. Starting from batch ${startFrom} (index ${startIndex}).`
  )

  for (let i = startIndex; i < batches.length; i++) {
    console.log('started batch', i + 1, 'of', batches.length)

    const batch = batches[i]

    // 1) Build prompt & write it to debug
    const prompt = buildPrompt(batch.content)
    await writeDebugFile(i, 'prompt.txt', prompt)

    // 2) Collect expected keys from NEW sections and write to debug
    const expectedKeys = extractKeysFromNewSections(batch.content)
    await writeDebugFile(
      i,
      'expected-keys.txt',
      expectedKeys.map((k) => `• ${k}`).join('\n') || '(none)'
    )

    // 3) Call the model
    const llmOutput = await runLLM(prompt)

    // 4) Always write RAW model output for inspection
    await writeDebugFile(i, 'output.raw.txt', llmOutput ?? '(undefined)')

    // 5) Parse (may still fail if the model returned junk; that’s ok, we have raw)
    const parsedOutput = llmOutput ? parseLLMOutput(llmOutput) : null

    // 6) Write a simple report comparing keys
    const report = buildKeyReport(expectedKeys, parsedOutput as unknown)
    await writeDebugFile(i, 'report.txt', report)

    // 7) Persist parsed output if present
    if (parsedOutput) {
      const outPath = await writeBatchJson(i, parsedOutput as any)

      const count = Array.isArray(parsedOutput)
        ? parsedOutput.length
        : Object.keys(parsedOutput as Record<string, unknown>).length

      console.log(
        `Wrote ${count} entr${count === 1 ? 'y' : 'ies'} → ${outPath}`
      )

      // Extra console hint if there were unexpected keys
      const unexpectedCount = report
        .split('\n')
        .find((l) => l.startsWith('Unexpected (returned but not expected):'))
      if (unexpectedCount && !unexpectedCount.endsWith(': 0')) {
        console.warn(
          `⚠️  Unexpected keys detected in batch ${i + 1}. See ${path.join(
            DEBUG_DIR,
            `batch-${String(i + 1).padStart(3, '0')}.report.txt`
          )}`
        )
      }
    } else {
      console.log(`No results from batch ${i + 1}`)
    }
  }

  console.log('Done.')
})()
