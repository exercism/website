export function buildPrompt(batchContent: string): string {
  return `
You are an assistant that extracts i18n metadata from TSX React component files.

Input format:
- Each file appears twice in the batch:
  - OLD: before i18n extraction, with literal user-facing text (or "[not found]").
  - NEW: after i18n extraction, with calls like t("...") or t('...').

Task:
- For every t("...") / t('...') key found in a NEW section, output exactly one object with:
  - "key": the exact key string as written in the code (copy verbatim).
  - "desc": a concise description (prefer 1 sentence; up to 3 only if truly necessary) of what the string represents in the UI, grounded by the OLD text if available.

Style rules for "desc":
- Each sentence must begin with "This is ...".
- Prefer precise UI nouns: "heading", "button label", "menu item", "tooltip", "helper text".
- Avoid filler like "the text for a button"; be specific and succinct.

Output rules:
- Output MUST be a single JSON array of objects. Do not return NDJSON, prose, or code fences.
- Preserve suffixes like "_html" in keys.
- Include ONLY keys that appear in NEW sections.
- Do not duplicate keys.

Example:
OLD:
  <h1>General settings</h1>
NEW:
  <h1>{t('.heading')}</h1>
Output:
  [
    {"key":".heading","desc":"This is the main heading for the general settings page."}
  ]

File batch content:
---
${batchContent}
---`.trim()
}
