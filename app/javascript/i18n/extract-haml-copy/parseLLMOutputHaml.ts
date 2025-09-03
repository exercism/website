import fs from 'fs/promises'
import path from 'path'
import yaml from 'yaml'

type AnyRecord = Record<string, any>

/**
 * Deep merge: merges b into a (objects only; arrays are replaced)
 */
function deepMerge<T extends AnyRecord>(a: T, b: T): T {
  const out: T = { ...a }
  for (const [k, v] of Object.entries(b)) {
    const existing = out[k]
    if (
      v &&
      typeof v === 'object' &&
      !Array.isArray(v) &&
      existing &&
      typeof existing === 'object' &&
      !Array.isArray(existing)
    ) {
      // @ts-expect-error recursive merge
      out[k] = deepMerge(existing, v)
    } else {
      // @ts-expect-error assignment
      out[k] = v
    }
  }
  return out
}

export async function parseLLMOutput(llmOutput: string) {
  const enStart = llmOutput.indexOf('\nen:')
  if (enStart === -1) {
    throw new Error('Could not find `en:` root in the LLM output.')
  }

  const hamlPart = llmOutput.slice(0, enStart).trim()
  const yamlPart = llmOutput.slice(enStart).trim()

  const yamlRaw = extractYamlFromMixedText(llmOutput) // safer than manual slicing
  const yamlWithoutRoot = stripEnRoot(yamlRaw)
  const sanitized = normalizeIndentAndSpaces(yamlWithoutRoot)

  let parsedYaml: AnyRecord
  try {
    parsedYaml = yaml.parse(sanitized)
  } catch (err) {
    // Extra debugging to locate the *actual* bad char
    const e = err as Error
    console.error('YAML parsing failed:\n', sanitized)
    console.error('--- visible char codes around error ---')
    const idx = (e as any).pos ?? -1 // eemeli/yaml sometimes includes .pos
    if (idx > -1) {
      const start = Math.max(0, idx - 80)
      const end = Math.min(sanitized.length, idx + 80)
      const window = sanitized.slice(start, end)
      console.error(
        window
          .split('')
          .map((c) => `${c}\\u${c.charCodeAt(0).toString(16).padStart(4, '0')}`)
          .join('')
      )
    }
    throw e
  }

  if (!parsedYaml || typeof parsedYaml !== 'object') {
    throw new Error('Parsed YAML was not an object.')
  }

  const firstKey = Object.keys(parsedYaml)[0]
  const secondLevel = parsedYaml[firstKey] as AnyRecord

  const outputByFile: Record<string, AnyRecord> = {}

  for (const [secondKey, value] of Object.entries(secondLevel)) {
    const filePath = path.join(
      process.cwd(),
      '../../..',
      'config',
      'locales',
      'views',
      firstKey,
      `${secondKey}.yml`
    )

    if (!outputByFile[filePath]) {
      outputByFile[filePath] = {}
    }

    outputByFile[filePath] = {
      ...outputByFile[filePath],
      ...(value as AnyRecord),
    }
  }

  for (const [filePath, data] of Object.entries(outputByFile)) {
    const namespace = path.basename(filePath, '.yml') // e.g. "show"

    let existing: AnyRecord = {}
    try {
      const raw = await fs.readFile(filePath, 'utf8')
      const parsedExisting = yaml.parse(raw) as AnyRecord | null
      if (parsedExisting && typeof parsedExisting === 'object') {
        existing = parsedExisting
      }
    } catch (e: any) {
      if (!e || e.code !== 'ENOENT') {
        throw e
      }
    }

    const existingSub =
      existing?.en?.[firstKey]?.[namespace] &&
      typeof existing.en[firstKey][namespace] === 'object'
        ? (existing.en[firstKey][namespace] as AnyRecord)
        : {}

    const mergedSub = deepMerge(existingSub, data as AnyRecord)

    const finalObj: AnyRecord = {
      en: {
        ...(existing.en ?? {}),
        [firstKey]: {
          ...(existing.en?.[firstKey] ?? {}),
          [namespace]: mergedSub,
        },
      },
    }

    const yamlDoc = new yaml.Document(finalObj)

    await fs.mkdir(path.dirname(filePath), { recursive: true })
    await fs.writeFile(filePath, yamlDoc.toString())
    console.log(`Saved YAML: ${filePath}`)
  }

  const sections = hamlPart.split(/# file: (.+)/g)
  const fileMap = new Map<string, string>()

  for (let i = 1; i < sections.length; i += 2) {
    const filePath = sections[i].trim()
    const content = sections[i + 1]?.trim()
    if (!filePath || !content) continue
    fileMap.set(filePath, content.replace(/^# end file\s*/gm, '').trim())
  }

  const viewsPath = path.join(process.cwd(), '../../..', 'app', 'views')

  for (const [relPath, content] of fileMap) {
    const relativeViewPath = relPath.replace(/^(\.\.\/)*views\//, '')
    const fullPath = path.join(viewsPath, relativeViewPath)
    await fs.mkdir(path.dirname(fullPath), { recursive: true })
    await fs.writeFile(fullPath, content + '\n')
    console.log(`Saved HAML: ${fullPath}`)
  }
}

// ensure consistent indentation inside literal (`|`) and folded (`>`) blocks
export function normalizeYamlBlocks(yamlText: string): string {
  const lines = yamlText.split('\n')
  let inBlock = false
  let blockIndent = 0

  return lines
    .map((line) => {
      if (!inBlock) {
        // detect start of a block scalar
        const m = /^(\s*[^:#\n]+:\s*[>|])([+-]?\d*)\s*$/.exec(line)
        if (m) {
          inBlock = true
          blockIndent = m[1].length // content must be indented > this
        }
        return line
      }

      // inside block: if next key (same or less indent) appears, we leave the block
      if (
        /^\s*[^#\s][^:\n]*:\s*(\S.*)?$/.test(line) &&
        line.search(/\S|$/) <= blockIndent
      ) {
        inBlock = false
        blockIndent = 0
        return line
      }

      // while in block, replace any leading tabs with spaces
      const leading = line.match(/^\s*/)?.[0] ?? ''
      const rest = line.slice(leading.length)
      const fixedLeading = leading.replace(/\t/g, '  ') // two spaces per tab
      return fixedLeading + rest
    })
    .join('\n')
}

// ————— helpers —————

/** Replace problematic whitespace that breaks YAML indentation */
function normalizeIndentAndSpaces(src: string): string {
  // Normalize line-endings first
  let s = src.replace(/\r\n?/g, '\n')

  // Replace leading tabs on every line with 2 spaces
  s = s.replace(/^\t+/gm, (m) => '  '.repeat(m.length))

  // Replace NBSP and other unicode spaces in indentation with normal spaces
  // (doing this only in the indentation segment avoids altering visible text)
  s = s.replace(
    /^([ \t\u00A0\u1680\u180E\u2000-\u200B\u202F\u205F\u3000]*)(.*)$/gm,
    (_all, indent: string, rest: string) =>
      indent.replace(
        /[\u00A0\u1680\u180E\u2000-\u200B\u202F\u205F\u3000]/g,
        ' '
      ) + rest
  )

  // Also squash accidental zero-width spaces anywhere
  s = s.replace(/[\u200B-\u200D\uFEFF]/g, '')

  return s
}

/** If your LLM output still contains fenced code blocks, isolate the YAML */
function extractYamlFromMixedText(llm: string): string {
  // Prefer fenced ```yaml ... ```
  const fence = /```yaml\s*([\s\S]*?)\s*```/i.exec(llm)
  if (fence) return fence[1].trimEnd() + '\n'

  // Else: take from the first exact "\nen:" until EOF (your current approach)
  const i = llm.indexOf('\nen:')
  if (i === -1) throw new Error('Could not find `en:` root in the LLM output.')
  return llm.slice(i + 1).trimEnd() + '\n'
}

/** Remove the top-level `en:` key while keeping the rest intact */
function stripEnRoot(yamlText: string): string {
  const lines = yamlText.split('\n')
  if (!/^en:\s*$/.test(lines[0])) {
    throw new Error('YAML does not start with `en:`')
  }
  return lines.slice(1).join('\n')
}
