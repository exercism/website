import path from 'path'
import { normalizePathForNamespace } from './normalizePathForNamespace'
import { toCamelCase } from './toCamelCase'

export function buildPrompt(
  files: Record<string, string>,
  folder: string
): string {
  const normalizedFolderPath = normalizePathForNamespace(folder)

  const fileSections = Object.entries(files)
    .map(([filePath, content]) => {
      const relativePath = path.relative(folder, filePath)
      const withoutExt = relativePath.replace(/\.[jt]sx$/, '')
      const parts = withoutExt.split(path.sep)
      const camelCaseParts = parts.map((part) => toCamelCase(part))
      const keyPrefix = camelCaseParts.join('.')

      return `// file: ${filePath}
// i18n-key-prefix: ${keyPrefix}
// i18n-namespace: ${normalizedFolderPath}
${content}
// end file`
    })
    .join('\n\n')

  const instructions = `You're given several TypeScript React files (with JSX). Your job is to:

1. Extract all visible UI text meant for display to users.
2. Replace visible text with i18n \`t('<i18n-key-prefix>.<key>')\` calls.
3. Use the \`i18n-key-prefix\` comment above each file to **prefix ALL keys in that file**.
   - This prefix becomes part of the full key path passed into \`t()\`.
   - Example:
     - If \`i18n-key-prefix: info.outdated\` and a key is \`solutionWasSolved\`
     - Then the call should be: \`t('info.outdated.solutionWasSolved')\`
     - And the translation output should be:
       \`\`\`ts
       export default {
         "info.outdated.solutionWasSolved": "This solution was solved against an older version of this exercise"
       }
       \`\`\`
   - Do **not** use nested objects in the output. All translation keys must be flat strings.
   - This key prefix should be concise and descriptive, like \`info.outdated\`, \`difficulty.easy\`, or \`exerciseTypeTag.learningExercise\`. Don't concatenate the whole text into one string as use it as a key!!

4. Use the \`i18n-namespace\` comment above each file for the \`useAppTranslation('<namespace>')\` call.
   - You MUST import it like this at the top of the file:
     \`\`\`ts
     import { useAppTranslation } from '@/i18n/useAppTranslation'
     \`\`\`
   - This ensures i18n is initialized globally and avoids repeating \`initI18n()\` per file.
5. Do NOT import from \`react-i18next\` directly — always use \`useAppTranslation\`.
6. Ensure the i18n output is valid TypeScript: \`export default { ... }\`
7. All keys must use camelCase. Never use the original UI string as a key.

---

### CRITICAL RULES FOR TEXT EXTRACTION:

1. **ONLY extract the visible text. NEVER extract JSX or HTML markup.**
   - From: \`<div className="icon"></div>Easy\` → Extract: \`"Easy"\`
   - From: \`<GraphicalIcon icon="concept-exercise" /> Learning Exercise\` → Extract: \`"Learning Exercise"\`

2. **Handle JSX components and variables intelligently:**
   - Replace visible text with a \`t()\` call and include dynamic values as:
     - Component placeholders (e.g., \`<trackIcon/>\`)
     - Mustache variables (e.g., \`{{trackTitle}}\`)
   - Do **not** split static and dynamic parts across separate JSX nodes. Include the whole phrase in \`t()\`.
   - Examples:

     **Original:**
     \`\`tsx
     {t('info.titleInTrack')} <TrackIcon ... /> <div>{track.title}</div>
    \`\`\`

     **Incorrect translation:**
     \`\`\`ts
     "info.titleInTrack": "in"
     \`\`\`

     **Correct result:**
     \`\`\`tsx
     {t('info.titleInTrack', {
       trackTitle: track.title,
     })}
     \`\`\`

     **Translation:**
     \`\`\`ts
     "info.titleInTrack": "in <trackIcon/> <trackTitle>{{trackTitle}}</trackTitle>"
     \`\`\`

   - You MUST include meaningful dynamic content in the translation string if:
     - The phrase structure depends on it
     - The ordering of the phrase might differ between languages

   - Simple property access like \`{exercise.title}\` can stay in the JSX as-is **only when not tied to translatable phrases**.

---

### CRITICAL: React Hook Rules

**ALWAYS place the \`useAppTranslation\` hook INSIDE the React component function, never outside.**

**Correct:**
\`\`\`tsx
export const MyComponent = () => {
  const { t } = useAppTranslation('<i18n-namespace>')
  return <div>{t('key')}</div>
}
\`\`\`

**WRONG - Never do this:**
\`\`\`tsx
const { t } = useAppTranslation('<i18n-namespace>') // ← WRONG: Outside component
export const MyComponent = () => {
  return <div>{t('key')}</div>
}
\`\`\`

---

### Example of correct transformation

**Original:**
\`\`\`tsx
// i18n-key-prefix: info.outdated
// i18n-namespace: components/common/exercise-widget

const { t } = useAppTranslation()
export const OutdatedComponent = () => {
  return <Icon alt="This solution was solved against an older version of this exercise" />
}
\`\`\`

**Should become:**
\`\`\`tsx
export const OutdatedComponent = () => {
  const { t } = useAppTranslation('components/common/exercise-widget')
  return <Icon alt={t('info.outdated.solutionWasSolved')} />
}
\`\`\`

**Translation file:**
\`\`\`ts
export default {
  "info.outdated.solutionWasSolved": "This solution was solved against an older version of this exercise"
}
\`\`\`

---

### Key naming rules

- Use **camelCase** for all keys.
- NEVER use raw UI strings as keys.
- NEVER include JSX/HTML markup in translation values.
- Only use variables when necessary:
  - ✅ Computed or dynamic expressions
  - ✅ Combining strings + variables
  - ❌ Simple property access like \`{user.name}\`

---

### Response format

Return your response in this format:

\`\`\`ts
// i18n
export default {
  "info.outdated.solutionWasSolved": "This solution was solved against an older version of this exercise",
  "difficulty.easy": "Easy",
  "exerciseTypeTag.learningExercise": "Learning Exercise"
}

// modified_files
// === file: ../components/common/exercise-widget/info/Outdated.tsx ===
... updated code ...
// === end file ===
\`\`\`

Remember:
- Output must be a **flat object with dot-separated keys**
- Use the correct \`i18n-key-prefix\` for all keys
- Use the correct \`i18n-namespace\` for \`useAppTranslation()\`
- **ALWAYS place \`useAppTranslation\` hook INSIDE the React component function**
`

  return `${instructions}\n\n${fileSections}`
}
