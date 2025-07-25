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
# i18n-key-prefix: ${keyPrefix}
# i18n-namespace: ${namespace}
${content}
# end file`
    })
    .join('\n\n')

  const instructions = `You're given Ruby on Rails view files written in HAML. Your task is to:

1. Extract all user-visible strings and replace them with appropriate \`= t('...')\` i18n calls.
2. Use the \`i18n-key-prefix\` comment as the flat dot-separated key prefix for each file.
3. Respect pluralization conventions (e.g., \`key_one\`, \`key_other\`).
4. Preserve all indentation and formatting of the HAML.
5. Replace interpolated Ruby like \`"Welcome #{user.name}"\` with:
   - \`= t('some.key', user_name: user.name)\`
   - and in translations: \`some.key: "Welcome %{user_name}"\`

---

💡 Output must be valid **JSON**, not YAML, and must follow this exact structure:

\`\`\`json
{
  "translations": {
    "some.key": "Some translation",
    "some.other_key_one": "One item",
    "some.other_key_other": "%{count} items"
  },
  "modifiedFiles": {
    "path/to/file.html.haml": "...translated haml content..."
  },
  "namespace": "views.about"
}
\`\`\`

❌ DO NOT wrap the response in triple backticks — just return raw JSON.

✅ DO NOT nest translation keys. Only use flat keys like \`some.key\`.

🛑 DO NOT modify any file paths or names — return exactly what was passed in.

Begin processing:
`

  return `${instructions}\n\n${fileSections}`
}
