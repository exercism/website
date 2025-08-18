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
   - This key prefix should be CONCISE!!! and SHORT!!! and DESCRIPTIVE, like \`info.outdated\`, \`difficulty.easy\`, or \`exerciseTypeTag.learningExercise\`. Don't concatenate the whole text into one string as use it as a key!!

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

1. **ONLY extract visible text meant for users. NEVER extract JSX or HTML markup unless it's required for the phrase.**
   - ✅ Extract: \\"Easy\\" from \`<div className="icon"></div>Easy\`
   - ✅ Extract: \\"Learning Exercise\\" from \`<GraphicalIcon icon="concept-exercise" /> Learning Exercise\`

2. **Use \`t()\` for plain strings or those with mustache-style dynamic values.**
   - ✅ Example:
     \`\`\`tsx
     t('info.messageWithName', { name: user.name })
     \`\`\`
     with translation:
     \`\`\`ts
     "info.messageWithName": "Hello {{name}}"
     \`\`\`

3. **Use \`<Trans>\` when the translated text includes embedded components (like icons, buttons, or spans).**
   - ✅ Correct:
     \`\`\`ts
     "trackMenu.seeTrackOnGithub": "See {{trackTitle}} track on Github <icon/>"
     \`\`\`

     \`\`\`tsx
     <Trans
       i18nKey="trackMenu.seeTrackOnGithub"
       values={{ trackTitle: track.title }}
       components={{ icon: <GraphicalIcon icon="external-link" /> }}
     />
     \`\`\`

   - ❌ Do **not** attempt this with \`t()\`, because JSX elements like \`<GraphicalIcon />\` cannot be rendered inside a string returned from \`t()\`.

4. **If the tag in the translation string is not a simple, valid static HTML tag (like \`<strong>\` or \`<b>\`), you MUST use \`<Trans>\` and register the tag as a component.**
   - ✅ Valid: \`<strong>\`, \`<b>\` → still prefer \`<Trans>\` if classNames or nesting are present.
   - ❌ Avoid embedding JSX directly in the translation string with \`t()\`.

5. **Always include the entire user-facing phrase in a single translation unit.**  
   Do NOT split strings across multiple \`t()\` or \`Trans()\` calls. Include dynamic values and embedded components inline.

   ✅ Correct:
   \`\`\`tsx
   <Trans
     i18nKey="info.titleInTrack"
     values={{ trackTitle: track.title }}
     components={{ icon: <TrackIcon /> }}
   />
   \`\`\`

   With:
   \`\`\`ts
   "info.titleInTrack": "In <icon/> {{trackTitle}}"
   \`\`\`

   - You MUST include meaningful dynamic content in the translation string if:
     - The phrase structure depends on it
     - The ordering of the phrase might differ between languages

   - Simple property access like \`{exercise.title}\` can stay in the JSX as-is **only when not tied to translatable phrases**.


   ### 🧩 Sentences Must Remain Intact — Do NOT Slice Text Across \`t()\` Calls

Translations only make sense when full human-readable sentences are preserved.  
**Do NOT split sentences across multiple \`t()\` calls** — especially not between plain text and dynamic content or links.

---

#### ❌ Bad example — sliced into fragments:
\`\`\`tsx
<p>
  {t('tutorialCompletedModal.readyToGetStuck')}
  <a href={link}>{t('tutorialCompletedModal.realExercises')}</a>
  {t('tutorialCompletedModal.weHaveAlsoRevealed', { trackTitle })}
  {conceptCount} {t('tutorialCompletedModal.conceptCountPlural')}
</p>
\`\`\`

This is bad because:
- Each part is treated as a separate translation fragment.
- The sentence cannot be rearranged or translated correctly in non-English languages.
- It's unmaintainable for translators and results in awkward phrasing.

---

#### ✅ Correct — full sentence wrapped with variables/components:
\`\`\`tsx
<Trans
  i18nKey="tutorialCompletedModal.revealMessage"
  values={{ trackTitle, conceptCount }}
  components={{
    br: <br />,
    a: <a href={link} />,
  }}
/>
\`\`\`

\`\`\`ts
export default {
  "tutorialCompletedModal.revealMessage":
    "You're ready to get stuck in! <a>Start solving real exercises</a>.<br/>We've also revealed {{conceptCount}} new concepts in {{trackTitle}}."
}
\`\`\`

---

✅ This allows translators to re-order and translate the entire thought accurately.

🚫 Never break a single sentence across multiple \`t()\` or \`Trans\` calls — **treat each human sentence as one unit**.
---

### 🔢 Pluralization Rules (with \`count\`)

When extracting a phrase that involves a number (like “1 comment” or “2 comments”), you MUST:

1. Use \`t('key', { count })\` for pluralized values.
2. Define multiple translation keys in the output using suffixes:
   - \`key_one\`: used when \`count === 1\`
   - \`key_other\`: used for \`count !== 1\`
   - \`key_zero\` is optional — use it if English or your design requires “No X”

---

#### ✅ Example with \`t()\`:

**Original JSX:**
\`\`\`tsx
{commentCount} {pluralize('comment', commentCount)}
\`\`\`

**Becomes:**
\`\`\`tsx
t('stats.commentCount', { count: commentCount })
\`\`\`

**With i18n output:**
\`\`\`ts
export default {
  "stats.commentCount_one": "{{count}} comment",
  "stats.commentCount_other": "{{count}} comments"
}
\`\`\`

---

#### ✅ Example with \`<Trans>\`:

**JSX:**
\`\`\`tsx
<Trans
  i18nKey="stats.commentCount"
  count={count}
  values={{ count }}
  components={{ icon: <CommentIcon /> }}
/>
\`\`\`

**Translation:**
\`\`\`ts
"stats.commentCount_one": "<icon/> {{count}} comment",
"stats.commentCount_other": "<icon/> {{count}} comments"
\`\`\`

---

### 🚫 DO NOT:
- Manually call \`pluralize()\`, \`Intl.PluralRules\`, or write \`count === 1 ? ... : ...\` logic.
- Use a single string like \`"{{count}} comments"\` for all counts.

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
