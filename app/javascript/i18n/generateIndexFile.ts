import fs from 'fs/promises'
import path from 'path'

const EN_FOLDER = path.resolve('./en')
const OUTPUT_FILE = path.join(EN_FOLDER, 'index.ts')

function toSafeIdentifier(input: string): string {
  return input.replace(/[^a-zA-Z0-9]/g, '')
}

async function generateEnIndex() {
  const entries = await fs.readdir(EN_FOLDER)

  const index: { importName: string; importPath: string; namespace: string }[] =
    []

  for (const entry of entries) {
    if (!entry.endsWith('.ts') || entry === 'index.ts') continue

    const filePath = path.join(EN_FOLDER, entry)
    const content = await fs.readFile(filePath, 'utf8')

    const namespaceMatch = content.match(/\/\/\s*namespace:\s*(.+)/)
    if (!namespaceMatch) {
      console.warn(` Skipping ${entry} — no // namespace: comment found.`)
      continue
    }

    const namespace = namespaceMatch[1].trim()
    const importName = toSafeIdentifier(entry.replace(/\.ts$/, ''))
    const importPath = `./${entry.replace(/\.ts$/, '')}`

    index.push({ importName, importPath, namespace })
  }

  const importLines = index.map(
    ({ importName, importPath }) => `import ${importName} from '${importPath}'`
  )

  const exportLines = index.map(
    ({ namespace, importName }) => `  '${namespace}': ${importName},`
  )

  const output = [
    ...importLines,
    '',
    'export default {',
    ...exportLines,
    '};',
    '',
  ].join('\n')

  await fs.writeFile(OUTPUT_FILE, output)
  console.log('Generated en/index.ts with', index.length, 'entries.')
}

generateEnIndex().catch((err) => {
  console.error('Failed to generate en/index.ts:', err)
  process.exit(1)
})
