#!/usr/bin/env ts-node

import fs from 'fs/promises'
import { parseLLMOutput } from './parseLLMOutputHaml'

async function main() {
  const [inputPath] = process.argv.slice(2)
  if (!inputPath) {
    console.error('Usage: applyLLMOutput.ts <file.txt>')
    process.exit(1)
  }

  try {
    const content = await fs.readFile(inputPath, 'utf8')
    await parseLLMOutput(content)
  } catch (err) {
    console.error('Error applying LLM output:', err)
    process.exit(1)
  }
}

main()
