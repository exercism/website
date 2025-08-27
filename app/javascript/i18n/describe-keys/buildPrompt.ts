export function buildPrompt(batchContent: string): string {
  return `
You are an assistant that extracts i18n metadata from TSX React component files.

Task:
- The batch contains **two versions** of each file:
  - (OLD) version: before i18n extraction, with literal user-facing text.
  - (NEW) version: after i18n extraction, using translation calls like \`t("...")\` or \`t('...')\`.
- For every translation key found in the NEW version, output one JSON object with:
  - "key": the exact i18n key string used in the code (do not modify, expand, or rename it).
  - "desc": a short description (1–3 sentences) of what the string represents in the UI.
- Use the OLD version’s text to ground your description and avoid hallucinations.

Rules:
- The "key" must be exactly the same string as in the code, including dots and suffixes (e.g., \`.github.connect_button\` stays exactly that).
- Each sentence in "desc" must begin with "This is ...".
- Maximum of 3 sentences if more detail is necessary.
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
  {"key":".heading","desc":"This is the main heading for the general settings page."}

File batch content:
---
${batchContent}
---`.trim()
}
