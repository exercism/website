// buildPromptHaml.ts
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

  const instructions = `You're given several Ruby on Rails view files written in HAML. Your task is to:

1. Extract all user-facing visible text.
2. Replace it with i18n calls using \`= t('<i18n-key-prefix>.<key>')\` or \`= t('<key>', count: ...)\`.
3. Use the provided \`i18n-key-prefix\` as a flat dot-separated prefix for all keys in that file.
4. Use Rails' pluralization system properly (e.g., key_one, key_other).
5. Preserve the original indentation and formatting of the HAML.
6. Output translations as a flat YAML object under \`en:\`.

---

Output format must include:

1. A valid YAML export starting with:
   
   \`\`\`yaml
  en:
  some.key: "Some value"
  another.key_one: "1 item"
  another.key_other: "%{count} items"
    \`\`\`

2. Then list of modified files like this:

\`\`\`
# === file: path / to / file.html.haml ===
...updated haml content...
# === end file ===
    \`\`\`

---

Rules:
- DO NOT use nested keys — only flat dot-separated keys.
- DO NOT translate variable names (e.g., %{name}, %{count})
- DO NOT translate markup or Rails helpers — only user-visible text.
- Detect pluralizations and dynamic variables properly.
- NEVER break full sentences into multiple keys.
- ALWAYS preserve the indentation in the HAML output.
- 🔄 Interpolated Ruby strings like \`"Welcome #{user.name}"\` must be rewritten to:
  - \`= t('some.key', user_name: user.name)\`
  - with YAML: \`some.key: "Welcome %{user_name}"\`

Begin now.
`

  return `${instructions}\n\n${fileSections}`
}
