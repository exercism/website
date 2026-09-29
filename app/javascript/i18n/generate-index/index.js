#!/usr/bin/env node
/*
 * Regenerates app/javascript/i18n/en/index.ts, the aggregated catalogue that
 * i18n.ts imports. One entry per namespace file in en/, keyed by the namespace
 * its `// namespace:` comment declares.
 *
 * Two properties matter as much as correctness, because both were once wrong
 * and each turned a one-file change into a ~480-line diff:
 *
 * 1. Import names are derived from the filename, never from the entry's
 *    position. Position-based names (aa, ab, ac, ...) meant inserting a
 *    namespace near the top renamed every entry after it.
 *
 * 2. Output is formatted with the project's Prettier config, because the
 *    pre-commit hook runs Prettier over staged files. Unformatted output left
 *    every line Prettier wraps flipping between two forms.
 *
 * Together these make the diff for adding a namespace exactly the two lines
 * that namespace owns. `yarn i18n-generate` is idempotent: running it when
 * nothing changed leaves the file byte-identical.
 */

const fs = require('fs/promises')
const path = require('path')
const prettier = require('prettier')

// Relative to this file, not the cwd, so the script works from any directory.
const EN_FOLDER = path.join(__dirname, '..', 'en')
const OUTPUT_FILE = path.join(EN_FOLDER, 'index.ts')

// Every non-alphanumeric run is a word break, including the '.' in
// `Foo.tsx.ts`. That is what keeps `Foo.tsx.ts` and `foo.ts` — both of which
// exist here — from collapsing onto the same identifier.
function toImportName(fileName) {
  const stem = fileName.replace(/\.ts$/, '')
  const words = stem.split(/[^A-Za-z0-9]+/).filter(Boolean)

  const camel = words
    .map((word, i) => (i === 0 ? word : word[0].toUpperCase() + word.slice(1)))
    .join('')
  const ident = camel[0].toLowerCase() + camel.slice(1)

  // A leading digit is not a valid identifier start.
  return /^[A-Za-z_$]/.test(ident) ? ident : `_${ident}`
}

async function generateEnIndex() {
  const entries = await fs.readdir(EN_FOLDER)

  const index = []
  const takenBy = new Map()

  for (const entry of entries.sort()) {
    if (!entry.endsWith('.ts') || entry === 'index.ts') continue

    const content = await fs.readFile(path.join(EN_FOLDER, entry), 'utf8')

    const namespaceMatch = content.match(/\/\/\s*namespace:\s*(.+)/)
    if (!namespaceMatch) {
      console.warn(`Skipping ${entry} — no // namespace: comment found.`)
      continue
    }

    const importName = toImportName(entry)
    const clash = takenBy.get(importName)
    if (clash) {
      throw new Error(
        `${entry} and ${clash} both map to the import name '${importName}'. ` +
          `Rename one of them so each file gets its own identifier.`
      )
    }
    takenBy.set(importName, entry)

    index.push({
      importName,
      importPath: `./${entry.replace(/\.ts$/, '')}`,
      namespace: namespaceMatch[1].trim(),
    })
  }

  index.sort((a, b) => a.namespace.localeCompare(b.namespace))

  const source = [
    ...index.map(
      ({ importName, importPath }) =>
        `import ${importName} from '${importPath}'`
    ),
    '',
    'export default {',
    ...index.map(
      ({ namespace, importName }) => `  '${namespace}': ${importName},`
    ),
    '};',
    '',
  ].join('\n')

  const config = await prettier.resolveConfig(OUTPUT_FILE)
  const formatted = prettier.format(source, {
    ...config,
    filepath: OUTPUT_FILE,
  })

  const existing = await fs.readFile(OUTPUT_FILE, 'utf8').catch(() => null)
  if (existing === formatted) {
    console.log(`en/index.ts already up to date (${index.length} entries).`)
    return false
  }

  await fs.writeFile(OUTPUT_FILE, formatted)
  console.log(`Generated en/index.ts with ${index.length} entries.`)
  return true
}

module.exports = { generateEnIndex, toImportName }

if (require.main === module) {
  generateEnIndex().catch((err) => {
    console.error(err.message || err)
    process.exit(1)
  })
}
