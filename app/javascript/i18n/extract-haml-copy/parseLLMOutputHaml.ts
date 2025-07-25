// parseLLMOutputHaml.ts
import yaml from 'yaml'

export function parseLLMOutput(text: string): {
  translations: string
  files: Record<string, string>
} {
  // Extract YAML between ```yaml and ```
  const yamlMatch = text.match(/```yaml\n([\s\S]*?)\n```/)
  if (!yamlMatch) throw new Error('No YAML block found in LLM output.')

  const yamlContent = yamlMatch[1].trim()

  // Remove the top-level `en:` key and flatten the YAML content
  const parsedYaml = yaml.parse(yamlContent)
  if (!parsedYaml?.en || typeof parsedYaml.en !== 'object') {
    throw new Error('YAML block must start with "en:"')
  }

  const flatYaml = Object.entries(parsedYaml.en)
    .map(([k, v]) => `${k}: ${JSON.stringify(v)}`)
    .join('\n')

  // Parse modified files
  const fileSections = text.split(/# === file: (.*?) ===/g).slice(1)
  const files: Record<string, string> = {}

  for (let i = 0; i < fileSections.length; i += 2) {
    const filePath = fileSections[i].trim()
    const content = fileSections[i + 1]?.split('# === end file ===')[0]?.trim()
    if (filePath && content) {
      files[filePath] = content
    }
  }

  if (Object.keys(files).length === 0) {
    console.warn('No modified files found in LLM output.')
  }

  return {
    translations: `en:\n${flatYaml}`,
    files,
  }
}
