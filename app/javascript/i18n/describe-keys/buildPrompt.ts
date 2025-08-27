export function buildPrompt(batchContent: string): string {
  return `
You are an assistant that extracts i18n metadata from template files.

Task:
- Find all translation calls like \`t('.heading')\` or \`t('.github.connect_button')\` in the file below.
- For each, output a JSON object with:
  - "key": the full i18n key, expanded relative to the file path.
  - "desc": a very short description (1 sentence max) of what the string does in the UI.

Rules:
- Output format must be NDJSON (one JSON object per line).
- No extra text, no explanations, no Markdown code fences.
- If the key ends in \`_html\`, keep it.
- Use only the keys actually present in the file.

Example:
Input snippet:
  %h1= t('.heading')
Output:
  {"key":"page_settings_general.heading","desc":"Main heading for general settings page"}

File batch content:
---
${batchContent}
---`.trim()
}
