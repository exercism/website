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
-# i18n-namespace: ${namespace}
${content}
# end file`
    })
    .join('\n\n')

  const instructions = `You are given one or more Ruby on Rails view files written in HAML.

Your task is to:

1. Extract all **user-visible strings** and replace them with \`= t('...')\` translation calls.
2. Use the \`# i18n-key-prefix\` as the prefix for all translation keys in that file.
3. Add a \`# i18n-namespace\` and other comments (already shown above each file) at the top of each returned HAML string.
4. Replace interpolated Ruby (e.g. \`"Hello \#{user.name}"\`) with:
   - \`= t('some.key', user_name: user.name)\` in HAML
   - \`some.key: "Hello %{user_name}"\` in the translation output.
5. Handle pluralization properly by using keys like \`key_one\` and \`key_other\`.

---

The final result must be valid **raw JSON** following this exact structure:

{
  "translations": {
    "some.key": "Translation here",
    "some.key_one": "1 item",
    "some.key_other": "%{count} items"
  },
  "modifiedFiles": {
    "relative/path/to/file.html.haml": "# i18n-key-prefix: ...\\n# i18n-namespace: ...\\n...translated HAML here..."
  },
  "namespace": "${namespace}"
}

---

DO NOT:
- Do **not** wrap the JSON in \`\`\`json or \`\`\` — just return valid raw JSON.
DO NOT wrap your JSON response in triple backticks like \`\`\`json or \`\`\`.
This breaks JSON parsing and will make your response unusable.
Just return raw JSON only — no Markdown formatting, no comments, no decoration.
- Do **not** output YAML, Markdown, or commentary.
- Do **not** nest translation keys — all keys must be **flat** (e.g. \`a.b.c\`, not \`a: { b: { c: ... } }\`).
- Do **not** include extra comments or explanations outside the JSON.
- Do **not** change any filenames or paths — return exactly what was passed in.

The output will be parsed **automatically** as JSON, so:
- Escape double quotes properly.
- Ensure all strings are valid JSON strings.
- Avoid trailing commas.
- Make sure the entire output is syntactically valid JSON.

Begin processing:
`

  return `${instructions}\n\n${fileSections}`
}
