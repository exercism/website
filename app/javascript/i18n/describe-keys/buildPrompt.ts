export function buildPrompt(batchContent: string): string {
  return `
You are an assistant that extracts i18n metadata from TSX React component files.

Task:
- The batch contains **two versions** of each file:
  - (OLD) version: before i18n extraction, with literal user-facing text.
  - (NEW) version: after i18n extraction, using translation calls like \`t('.heading')\`.
- For every translation key found in the NEW version, output one JSON object with:
  - "key": the full i18n key, expanded relative to the file path.
  - "desc": a very short description (1 sentence max) of what the string represents in the UI.
- Use the OLD version’s text to ground your description and avoid hallucinations.

Rules:
- Output format must be NDJSON (one JSON object per line).
- Do not output any explanations, extra text, or Markdown code fences.
- Keep \`_html\` suffixes in keys if present.
- Only include keys that actually appear in the NEW version of the files.

Example:
OLD:
  <h1>General settings</h1>
NEW:
  <h1>{t('.heading')}</h1>
Output:
  {"key":"page_settings_general.heading","desc":"Main heading for general settings page"}

File batch content:
---
${batchContent}
---`.trim()
}
