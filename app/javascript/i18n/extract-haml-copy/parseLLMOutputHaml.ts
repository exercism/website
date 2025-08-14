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

  const yamlWithoutRoot = yamlPart.split('\n').slice(1).join('\n')

  let parsedYaml: AnyRecord
  try {
    parsedYaml = yaml.parse(yamlWithoutRoot)
  } catch (err) {
    console.error('YAML parsing failed:')
    console.error(yamlWithoutRoot.slice(0, 500))
    throw new Error(err instanceof Error ? err.message : String(err))
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
