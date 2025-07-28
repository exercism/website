import path from 'path'
import { toCamelCase } from '../extract-jsx-copy/toCamelCase'
import { normalizePathForNamespace } from '../extract-jsx-copy/normalizePathForNamespace'

export function buildPrompt(
  files: Record<string, string>,
  rootFolder: string
): string {
  const namespace = normalizePathForNamespace(rootFolder)
  const fileSections = Object.entries(files)
    .map(([filePath, content]) => {
      const relativePath = path.relative(rootFolder, filePath)
      const withoutExt = relativePath.replace(/\.html\.haml$/, '')
      const parts = withoutExt.split(path.sep)
      const camelParts = parts.map(toCamelCase)
      const keyPrefix = camelParts.join('.')
      return `# file: ${filePath}
-# i18n-key-prefix: ${keyPrefix}
${content}
# end file`
    })
    .join('\n\n')

  const instructions = `You are given one or more Ruby on Rails view files written in HAML.

Your task is to extract all **user-visible strings** and create translation keys for them.

For each user-visible string:
1. Create a descriptive translation key using the provided i18n-key-prefix
2. Replace interpolated Ruby (e.g. "Hello #{user.name}") with placeholder format (e.g. "Hello %{user_name}")
3. Handle pluralization with keys ending in _one and _other

Translation key rules:
- Use the provided i18n-key-prefix as prefix (e.g. "hiringDeveloper")  
- Be descriptive and readable
- Use only lowercase letters (a-z) and dots as separators
- No underscores, dashes, numbers, or special characters except for pluralization (_one, _other)
- Examples: "hiringDeveloper.title", "aboutPage.welcomeMessage"

Output ONLY a valid JSON object with the extracted translations:

{
  "some.key": "Translation text here",
  "some.key.another": "More text",
  "pluralized.key_one": "1 item", 
  "pluralized.key_other": "%{count} items"
}

IMPORTANT:
- Output ONLY valid JSON - no code blocks, no explanations, no extra text
- Do NOT wrap in \`\`\`json or any other formatting
- Do NOT include any text before or after the JSON object
- Use double quotes for all strings
- No trailing commas

Now process the following files:
`

  return `${instructions}\n\n${fileSections}`
}
