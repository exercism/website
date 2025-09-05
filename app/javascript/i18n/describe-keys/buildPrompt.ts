export function buildPrompt(batchContent: string): string {
  return `
You are an assistant that extracts i18n metadata from TSX React component files.

Scope:
- ONLY process files/sections that contain a \`t("...")\` or \`t('...')\` call in the NEW code.
- If a batch has no \`t(...)\` calls in any NEW section, respond with an empty JSON object: {}.
- Ignore <Trans i18nKey="..."> entirely for this task.

Goal:
- Output a single JSON OBJECT whose properties follow this exact format:
  "<EXACT i18n key from the code>": "<multi-line description>"

Key rules (CRITICAL):
- Use the EXACT key string as written inside \`t('...')\` or \`t("...")\`.
- Do NOT transform or infer namespaces.
- Do NOT add, remove, or modify leading dots, prefixes, or suffixes (e.g., keep ".heading", keep "_html").
- Do NOT deduce or prepend any namespace — the property name must match the code verbatim.

What to extract:
- Scan only the NEW sections to find all \`t("...")\` / \`t('...')\` usages.
- For every discovered key, create exactly one entry in the output JSON:
  - Property name: the exact key string from the code.
  - Property value: a single multi-line string with EXACTLY these fields, in this order,
    each on its own line starting with a bold label:
    **Functional Purpose**: <short, specific purpose in the UI>
    **UI Location**: <precise place in the UI hierarchy (e.g., "Settings → General → Header")>
    **When Users See This**: <concise trigger/context>
    **Technical Context**: <only relevant technical notes; list variables exactly and state they must remain unchanged>
    **Current English**: "<English text from OLD if available; else empty quotes>"

Grounding & variables:
- Use OLD text and nearby JSX to keep descriptions specific.
- If placeholders/variables appear (e.g., \`%{name}\`, \`{{count}}\`, \`{value}\`), list them under **Technical Context** EXACTLY as written and say "must remain unchanged".
- Be brief; do not over-explain obvious UI strings.
- Do not invent content not supported by OLD/NEW.

Deduplication:
- If the same exact key appears multiple times, include it once; the last occurrence wins.

Output rules:
- Output MUST be a single JSON object (not an array). No prose, comments, or code fences.
- Include ONLY keys found in NEW sections via \`t(...)\`.
- If no \`t(...)\` keys are found, output \`{}\`.

Example (conceptual):
OLD:
  <h1>General settings</h1>
NEW:
  <h1>{t('.heading')}</h1>

Output:
{
  ".heading": "**Functional Purpose**: Page heading for General settings\\n**UI Location**: Settings → General (page header)\\n**When Users See This**: On opening the General settings page\\n**Technical Context**: Standard text; no special formatting\\n**Current English**: \\"General settings\\""
}

Respond with a single JSON object only. Do not include code fences, comments, or extra text.

File batch content:
---
${batchContent}
---
`.trim()
}
