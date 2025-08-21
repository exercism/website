import fs from 'fs/promises'
import path from 'path'

const EN_FOLDER = path.resolve('./en')
const OUTPUT_FILE = path.join(EN_FOLDER, 'index.ts')

const RESERVED_WORDS = new Set([
  'do',
  'if',
  'for',
  'let',
  'var',
  'const',
  'class',
  'return',
  'function',
  'default',
  'import',
  'export',
  'switch',
  'case',
  'while',
  'break',
  'continue',
  'try',
  'catch',
  'finally',
  'throw',
  'new',
  'in',
  'typeof',
  'instanceof',
  'delete',
  'void',
  'with',
  'yield',
  'await',
  'this',
  'super',
  'extends',
  'static',
  'enum',
  'implements',
  'interface',
  'package',
  'private',
  'protected',
  'public',
  'null',
  'true',
  'false',
])

function toShortIdRaw(index: number): string {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789'
  let id = ''
  do {
    id = chars[index % chars.length] + id
    index = Math.floor(index / chars.length)
  } while (index > 0)
  return id.padStart(2, 'a')
}

function generateUniqueShortIds(count: number): string[] {
  const used = new Set<string>()
  const ids: string[] = []
  let i = 0

  while (ids.length < count) {
    const id = toShortIdRaw(i)
    i++

    if (RESERVED_WORDS.has(id) || used.has(id)) continue

    used.add(id)
    ids.push(id)
  }

  return ids
}

export async function generateEnIndex() {
  const entries = await fs.readdir(EN_FOLDER)

  const rawIndex: { importPath: string; namespace: string }[] = []

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
    const importPath = `./${entry.replace(/\.ts$/, '')}`

    rawIndex.push({ importPath, namespace })
  }

  rawIndex.sort((a, b) => a.namespace.localeCompare(b.namespace))

  const uniqueIds = generateUniqueShortIds(rawIndex.length)
  const index = rawIndex.map((entry, i) => ({
    ...entry,
    importName: uniqueIds[i],
  }))

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
