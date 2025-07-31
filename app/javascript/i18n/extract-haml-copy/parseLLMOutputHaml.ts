import fs from 'fs/promises'
import path from 'path'
import yaml from 'yaml'

export async function parseLLMOutput(llmOutput: string) {
  // Step 1: Split into HAML content and YAML content
  const enStart = llmOutput.indexOf('\nen:')
  if (enStart === -1) {
    throw new Error('Could not find `en:` root in the LLM output.')
  }

  const hamlPart = llmOutput.slice(0, enStart).trim()
  const yamlPart = llmOutput.slice(enStart).trim()

  // Step 2: Clean and parse YAML
  const yamlWithoutRoot = yamlPart
    .split('\n')
    .slice(1) // Remove the 'en:' line
    .join('\n')

  let parsedYaml: Record<string, any>
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

  const firstKey = Object.keys(parsedYaml)[0] // e.g. blog_posts
  const secondLevel = parsedYaml[firstKey] // e.g. { show: ..., index: ..., info_bar: ... }

  for (const secondKey of Object.keys(secondLevel)) {
    const perFileYaml = {
      en: {
        [firstKey]: {
          [secondKey]: secondLevel[secondKey],
        },
      },
    }

    const fileName = `${secondKey}.yml` // e.g. show.yml, index.yml, info_bar.yml

    const yamlOutputPath = path.join(
      process.cwd(),
      '../../..',
      'config',
      'locales',
      'views',
      firstKey // still use blog_posts directory
    )

    await fs.mkdir(yamlOutputPath, { recursive: true })

    const yamlFullPath = path.join(yamlOutputPath, fileName)
    const yamlDoc = new yaml.Document(perFileYaml)
    const yamlContent = yamlDoc.toString()

    await fs.writeFile(yamlFullPath, yamlContent)
    console.log(`Saved YAML: ${yamlFullPath}`)
  }

  // Step 3: Parse HAML sections
  const sections = hamlPart.split(/# file: (.+)/g)
  const fileMap = new Map<string, string>()

  for (let i = 1; i < sections.length; i += 2) {
    const filePath = sections[i].trim()
    const content = sections[i + 1]?.trim()
    if (!filePath || !content) continue
    fileMap.set(filePath, content.replace(/^# end file\s*/gm, '').trim())
  }

  // Step 4: Write HAML files
  // Step 4: Write HAML files
  const viewsPath = path.join(process.cwd(), '../../..', 'app', 'views')

  for (const [relPath, content] of fileMap) {
    const relativeViewPath = relPath.replace(/^(\.\.\/)*views\//, '')
    const fullPath = path.join(viewsPath, relativeViewPath)
    await fs.mkdir(path.dirname(fullPath), { recursive: true })
    await fs.writeFile(fullPath, content + '\n')
    console.log(`Saved HAML: ${fullPath}`)
  }
}
