export function buildPrompt(batchContent: string): string {
  return `
You are an assistant that extracts i18n metadata from TSX React component files.

Goal:
- Output a single JSON OBJECT whose properties follow this exact format:
  "[namespace]--[key]": "<multi-line description>"

Definitions:
- namespace (NS): the i18n namespace for the file/section.
- key (K): the key segment(s) relative to the namespace.
- Composite property name = \`\${NS}--\${K}\` (two hyphens). Do not alter dots within NS or K.

How to determine the namespace (NS), in priority order (first match wins):
1) From hooks/HOCs: \`useTranslation('NS')\`, \`useAppTranslation('NS')\`, \`withTranslation('NS')\`.
2) From JSX: \`<Trans i18nKey="NS.something">\` → NS = everything before the first dot.
3) From absolute \`t\` calls: \`t('NS.foo.bar')\` → NS = all segments before the last segment.
4) From an explicit marker comment if present: \`// i18n-ns: NS\`.
5) If none found, use \`global\`.

How to determine the key (K):
- If NEW uses relative keys: \`t('.foo.bar')\` → K = \`foo.bar\` (strip leading dot).
- If NEW uses absolute keys: \`t('NS.foo.bar')\` → K = \`foo.bar\`.
- If NEW uses a single-segment key with a known NS: \`t('submit')\` → K = \`submit\`.
- If no NS can be determined and the key is single-segment: NS = \`global\`, K = that segment.
- Preserve the full dot path inside K (e.g., \`summary.exercises_completed\`).

What to extract:
- Scan only the NEW sections to find all \`t("...")\` / \`t('...')\` usages and \`<Trans i18nKey="...">\`.
- For every discovered key, create exactly one entry in the output JSON:
  - Property name: \`\${NS}--\${K}\`
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
- Do not invent content not supported by OLD/NEW.
- Be brief; do not over-explain obvious UI strings.

Deduplication:
- If the same \`\${NS}--\${K}\` appears multiple times, include it once; the last occurrence wins.

Output rules:
- Output MUST be a single JSON object (not an array). No prose, comments, or code fences.
- Keys MUST be exactly \`\${namespace}--\${key}\` with two hyphens.
- Include ONLY keys found in NEW sections.

Example (conceptual):
OLD:
  <h1>General settings</h1>
NEW:
  const { t } = useTranslation('settings.general')
  <h1>{t('.heading')}</h1>

Output:
{
  "settings.general--heading": "**Functional Purpose**: Page heading for General settings\\n**UI Location**: Settings → General (page header)\\n**When Users See This**: On opening the General settings page\\n**Technical Context**: Standard text; no special formatting\\n**Current English**: \\"General settings\\""
}

Respond with a single JSON object only. Do not include code fences, comments, or extra text.

File batch content:
---
\${batchContent}
---
`.trim()
}
