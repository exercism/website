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

Translation keys must:
- Use the provided \`# i18n-key-prefix\` as a flat prefix (e.g. \`hiringDeveloper\`).
- Be **descriptive**, readable identifiers that clearly reflect the content.
- Use **only lowercase letters (a–z)** and **dots** as separators — no underscores, dashes, numbers, or special characters.
  - ✅ Valid: \`hiringDeveloper.title\`, \`aboutPage.missionStatement\`
  - ❌ Invalid: \`hiring.123_invalid\`, \`hiring.meta-title\`, \`aboutPage_1\`

---

The final result must be a valid raw **JavaScript object** using this exact structure:

{
  translations: {
    "some.key": "Translation here",
    "some.key_one": "1 item",
    "some.key_other": "%{count} items"
  },
  modifiedFiles: {
    "relative/path/to/file.html.haml": "# i18n-key-prefix: ...\\n# i18n-namespace: ...\\n...translated HAML here..."
  },
  namespace: "${namespace}"
}

---

DO NOT:
- Do NOT wrap the object in \`\`\`js or \`\`\` — just return the raw object literal.
- Do NOT output YAML, Markdown, or commentary.
- Do NOT nest translation keys — all keys must be **flat** (e.g. \`a.b.c\`, not \`a: { b: { c: ... } }\`).
- Do NOT include extra comments or explanations outside the object.
- Do NOT change any filenames or paths — return exactly what was passed in.
- Do NOT include \`\`\`javascript or \`\`\`js code blocks — only return the raw JS object.

 The output will be evaluated using \`Function("return (...)")()\`, so:


- Do NOT quote top-level keys (use: \`translations:\`, not \`"translations":\`).
- Strings must still use double quotes, like \`"some.key": "Value here"\`.
- No trailing commas.
- Escape any inner double quotes using \`\\\"\`.
- Do NOT use unescaped newlines in values.

If you break these rules, the system will crash.
If you output triple backticks like \`\`\`, the system will crash. Do NOT include them.

---

Now process the following files:

`

  return `${instructions}\n\n${fileSections}`
}
