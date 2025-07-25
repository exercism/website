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
    - Do **not** output YAML, Markdown, or commentary.
    - Do **not** nest translation keys — all keys must be **flat** (e.g. \`a.b.c\`, not \`a: { b: { c: ... } }\`).
    - Do **not** include extra comments or explanations outside the JSON.
    - Do **not** change any filenames or paths — return exactly what was passed in.
    
    The output will be parsed **automatically** as JSON, so:
    - Escape double quotes properly.
    - Ensure all strings are valid JSON strings.
    - Avoid trailing commas.
    - Make sure the entire output is syntactically valid JSON.

     IMPORTANT!! When building JSON:
    - Escape any inner double quotes with \\" inside translation values.
    - Do NOT include unescaped newlines or tab characters.
    - Strings must always be double-quoted and valid per JSON rules.

    You MUST output only raw, valid JSON. Follow these rules strictly:

    1. DO NOT wrap your response in triple backticks like \`\`\`json or \`\`\` — just return plain raw JSON.
    2. DO NOT include any comments or explanation.
    3. DO NOT include Markdown, YAML, or HTML. Only raw JSON is allowed.
    4. JSON MUST start with \`{\` and end with \`}\`.
    5. All string values and keys MUST be enclosed in double quotes.
    6. NO trailing commas are allowed.
    7. NO unescaped double quotes (\`"\`) inside strings.
      8. Keys must be valid JSON strings(letters, digits, underscores, and dots).
    9. The output will be parsed by\`JSON.parse\`.If the JSON is invalid, the process will fail.

    If you break these rules, the system will crash.
    
    Begin processing:
  `

  return `${instructions} \n\n${fileSections} `
}
