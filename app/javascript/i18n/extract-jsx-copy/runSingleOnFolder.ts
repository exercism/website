#!/usr/bin/env bun
import fs from 'fs/promises'
import path from 'path'
import { spawn } from 'child_process'

const targetScript = './extract-copy/index.ts'
const folder = process.argv[2]

if (!folder) {
  console.error('Please provide a folder path.')
  process.exit(1)
}

const supportedExtensions = ['.tsx', '.jsx']
const maxRetries = 5
const retryDelayMs = 2000

async function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

async function runSingleWithRetry(file: string) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    console.log(` [${attempt}/${maxRetries}] Running LLM on ${file}...`)
    const result = await runSingle(file)

    if (result.success) return

    const shouldRetry =
      result.error?.message?.includes('503') ||
      result.error?.message?.includes('overloaded') ||
      result.code !== 0

    if (attempt < maxRetries && shouldRetry) {
      console.warn(` Retry ${attempt} failed. Waiting ${retryDelayMs}ms...`)
      await delay(retryDelayMs)
    } else {
      console.error(`Failed after ${attempt} attempts:`, result.error)
      return
    }
  }
}

function runSingle(
  file: string
): Promise<{ success: boolean; code?: number; error?: Error }> {
  return new Promise((resolve) => {
    const child = spawn('bun', [targetScript, file, '--single'], {
      stdio: 'inherit',
    })

    child.on('exit', (code) => {
      if (code === 0) {
        resolve({ success: true })
      } else {
        resolve({ success: false, code: code ?? undefined })
      }
    })

    child.on('error', (err) => {
      resolve({ success: false, error: err })
    })
  })
}

async function main() {
  const entries = await fs.readdir(folder, { withFileTypes: true })

  for (const entry of entries) {
    if (
      entry.isFile() &&
      supportedExtensions.includes(path.extname(entry.name))
    ) {
      const filePath = path.join(folder, entry.name)
      await runSingleWithRetry(filePath)
    }
  }
}

main().catch((err) => {
  console.error('Fatal error:', err)
  process.exit(1)
})
