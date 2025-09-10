#!/usr/bin/env bun

/**
 * Verification script to ensure all i18n keys from source files
 * are present in the aggregated javascript-copy.ts file
 */

import { readFileSync, readdirSync } from 'fs'
import path from 'path'

// Import the aggregated resources
import resources from '../../i18n/javascript-copy'

const SOURCE_DIR = 'app/javascript/i18n/en'
const AGGREGATED_KEYS = new Set(Object.keys(resources.en.translation))

// Regex to match JavaScript object keys (both quoted and unquoted)
const KEY_REGEX =
  /(?<key>[a-zA-Z_][a-zA-Z0-9_]*|['"][^'"]*['"])\s*:\s*(?<val>"(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')/g

function extractKeysFromFile(filePath: string): string[] {
  const content = readFileSync(filePath, 'utf-8')
  const keys: string[] = []

  let match
  while ((match = KEY_REGEX.exec(content)) !== null) {
    let key = match.groups?.key
    if (!key) continue

    // Strip quotes from key if it's quoted
    if (key.startsWith('"') || key.startsWith("'")) {
      key = key.slice(1, -1)
    }

    keys.push(key)
  }

  return keys
}

function main() {
  console.log('🔍 Verifying i18n key completeness...\n')

  // Find all source translation files
  const sourceFiles = readdirSync(SOURCE_DIR)
    .filter((file) => file.endsWith('.ts'))
    .map((file) => path.join(SOURCE_DIR, file))

  console.log(`Found ${sourceFiles.length} source translation files`)
  console.log(`Aggregated file contains ${AGGREGATED_KEYS.size} keys\n`)

  let totalSourceKeys = 0
  let uniqueSourceKeys = new Set<string>()
  let missingKeys: string[] = []
  let extraKeys = new Set(AGGREGATED_KEYS)

  // Process each source file
  for (const filePath of sourceFiles) {
    const fileName = path.basename(filePath)
    console.log(`📂 Processing ${fileName}`)

    const keys = extractKeysFromFile(filePath)
    totalSourceKeys += keys.length

    for (const key of keys) {
      uniqueSourceKeys.add(key)

      if (!AGGREGATED_KEYS.has(key)) {
        missingKeys.push(`${fileName}: ${key}`)
      } else {
        extraKeys.delete(key) // Remove from extra keys set
      }
    }
  }

  console.log(`\n📊 Summary:`)
  console.log(`  Source files: ${sourceFiles.length}`)
  console.log(`  Total source keys: ${totalSourceKeys}`)
  console.log(`  Unique source keys: ${uniqueSourceKeys.size}`)
  console.log(`  Aggregated keys: ${AGGREGATED_KEYS.size}`)
  console.log(`  Missing keys: ${missingKeys.length}`)
  console.log(`  Extra keys: ${extraKeys.size}`)

  // Report missing keys
  if (missingKeys.length > 0) {
    console.log(`\n❌ Missing keys in aggregated file:`)
    missingKeys.forEach((key) => console.log(`  - ${key}`))
  }

  // Report extra keys (keys in aggregated but not in source)
  if (extraKeys.size > 0) {
    console.log(`\n⚠️  Extra keys in aggregated file (not found in source):`)
    Array.from(extraKeys).forEach((key) => console.log(`  - ${key}`))
  }

  // Final verdict
  if (missingKeys.length === 0 && extraKeys.size === 0) {
    console.log(`\n✅ All keys match! The aggregated file is complete.`)
    process.exit(0)
  } else {
    console.log(
      `\n❌ Key mismatch detected. Please run the aggregation script to sync.`
    )
    process.exit(1)
  }
}

try {
  main()
} catch (error) {
  console.error('Error:', error)
  process.exit(1)
}
