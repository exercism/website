// extract-and-prepare.ts
import fs from 'fs/promises'
import path from 'path'
import { GoogleGenAI } from '@google/genai'

const supportedExtensions = ['.tsx', '.jsx']

export async function readFilesInFolder(
  folder: string
): Promise<Record<string, string>> {
  const result: Record<string, string> = {}

  async function readRecursive(currentFolder: string) {
    const entries = await fs.readdir(currentFolder, { withFileTypes: true })

    for (const entry of entries) {
      const fullPath = path.join(currentFolder, entry.name)

      if (entry.isDirectory()) {
        await readRecursive(fullPath)
      } else if (supportedExtensions.includes(path.extname(entry.name))) {
        const content = await fs.readFile(fullPath, 'utf8')
        result[fullPath] = content
      }
    }
  }

  await readRecursive(folder)
  return result
}

function toCamelCase(str: string): string {
  return str
    .replace(/[-_\s]+(.)?/g, (_, char) => (char ? char.toUpperCase() : ''))
    .replace(/^[A-Z]/, (char) => char.toLowerCase())
}

function normalizePathForNamespace(inputPath: string): string {
  // Remove leading ../ and ./ and normalize separators
  const normalized = inputPath.replace(/^\.\.?\//g, '').replace(/\\/g, '/')
  return normalized
}

export function buildPrompt(
  files: Record<string, string>,
  folder: string
): string {
  const normalizedFolderPath = normalizePathForNamespace(folder)

  const fileSections = Object.entries(files)
    .map(([filePath, content]) => {
      // Get path relative to the target folder, not cwd
      const relativePath = path.relative(folder, filePath)
      const withoutExt = relativePath.replace(/\.[jt]sx$/, '')
      const parts = withoutExt.split(path.sep)

      // Convert each part to camelCase
      const camelCaseParts = parts.map((part) => toCamelCase(part))

      // Build the namespace path relative to the target folder
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
2. Replace visible text with i18n \`t('key')\` calls.
3. Use the \`i18n-key-prefix\` comment above each file to determine the FULL nested i18n key path inside the translation object. 

- This is NOT a flat key or label — it defines the full object nesting.
- For example: \`i18n-key-prefix: info.outdated\` means the key should be placed as \`info: { outdated: { ... } }\` in the output.
- \`i18n-key-prefix: difficulty\` means \`difficulty: { ... }\`.
- You MUST build the output structure to reflect the full nesting from this prefix.
4. Use the \`i18n-namespace\` comment above each file for the \`useTranslation('<namespace>')\` call. This is the full path to avoid collisions.
5. Replace \`useTranslation()\` with \`useTranslation('<i18n-namespace>')\` using the i18n-namespace value.
6. Ensure the i18n object is valid TypeScript: \`export default { ... }\`
7. Replace each visible string with a key in camelCase (never use UI text as keys).

---

### CRITICAL RULES FOR TEXT EXTRACTION:

1. **ONLY extract the actual TEXT content, NEVER JSX/HTML markup**
   - From: \`<div className="icon"></div>Easy\` → Extract: \`"Easy"\`
   - From: \`<GraphicalIcon icon="concept-exercise" /> Learning Exercise\` → Extract: \`"Learning Exercise"\`

2. **Handle JSX components and variables intelligently:**
   - JSX components should become placeholders: \`<TrackIcon .../>\` → \`<trackIcon/>\`
   - **Only create variables for truly dynamic content, not simple property access**
   - Simple property access like \`{exercise.title}\` should be kept as-is in the component, not turned into a variable
   - Only create variables when the content is computed or transformed
   
   **Examples:**
   - \`{exercise.title}\` → Keep as \`{exercise.title}\` in component, translation is just the static text
   - \`{pluralize('iteration', solution.numIterations)}\` → This should become \`{{pluralize}}\` because it's computed
   - \`{solution.numIterations}\` → This can stay as-is or become variable, depends on context
   
   **Good transformation:**
   \`\`\`jsx
   // Original:
   <span>Exercise: {exercise.title}</span>
   
   // Should become:
   <span>{t('exerciseLabel')}: {exercise.title}</span>
   
   // Translation:
   exerciseLabel: "Exercise"
  \`\`\`
   
   **Bad transformation:**
   \`\`\`jsx
   // Original:
   <span>Exercise: {exercise.title}</span>
   
   // Should NOT become:
   <span>{t('exerciseWithTitle', { exerciseTitle: exercise.title })}</span>
   
   // Translation:
   exerciseWithTitle: "Exercise: {{exerciseTitle}}"
   \`\`\`

3. **Namespace structure must reflect file hierarchy WITHIN the target folder:**
   - The \`i18n-key-prefix\` shows the path relative to the folder being processed
   - If namespace is \`info.outdated\`, the key goes under \`info.outdated\` in the output  
   - If namespace is \`info\`, the key goes under \`info\` in the output
   - If namespace is just a filename like \`difficulty\`, the key goes at the root level
   - Example structures:
   \`\`\`ts
   // For i18n-key-prefix: info.outdated
   export default {
     info: {
       outdated: {
         keyName: "value"
       }
     }
   }
   
   // For i18n-key-prefix: info  
   export default {
     info: {
       keyName: "value"
     }
   }
   
   // For i18n-key-prefix: difficulty
   export default {
     difficulty: {
       keyName: "value"
     }
   }
   \`\`\`

4. **All folder and file names must be converted to camelCase**
   - \`exercise-widget/Info\` → \`exerciseWidget.info\`
   - \`info/Outdated\` → \`info.outdated\`
   - \`SolutionStatusTag\` → \`solutionStatusTag\`

5. **The namespace structure directly maps to the output structure**
   - No top-level folder wrapping
   - Use the exact namespace path shown in \`i18n-key-prefix\`

6. **IMPORTANT: Use the i18n-namespace for useTranslation calls**
   - Always use the full \`i18n-namespace\` value in \`useTranslation('<i18n-namespace>')\`
   - This prevents collisions between different components with the same name

---

### Examples of correct extraction:

**Good - Simple property access stays in component:**
\`\`\`jsx
// Original:
<div className="--title">{exercise.title}</div>

// Should become:
<div className="--title">{exercise.title}</div>

// Translation: (no change needed, no translatable text)
\`\`\`

**Good - Only extract the translatable text:**
\`\`\`jsx
// Original:
<span>Exercise: {exercise.title}</span>

// Should become:
<span>{t('exerciseLabel')}: {exercise.title}</span>

// Translation:
exerciseLabel: "Exercise"
\`\`\`

**Good - Variables for computed/complex content:**
\`\`\`jsx
// Original:
<span>{solution.numIterations} {pluralize('iteration', solution.numIterations)}</span>

// Should become:
<span>{t('iterationsCount', { count: solution.numIterations, pluralize: pluralize('iteration', solution.numIterations) })}</span>

// Translation:
iterationsCount: "{{count}} {{pluralize}}"
\`\`\`

**Bad - Unnecessary variable creation:**
\`\`\`jsx
// Original:
<div className="--title">{exercise.title}</div>

// Should NOT become:
<div className="--title">{t('title', { exerciseTitle: exercise.title })}</div>

// Translation:
title: "{{exerciseTitle}}"
\`\`\`

---

### Namespace rules

- Convert all folder and file names to camelCase.
- The namespace structure directly maps to the output object structure.
- Examples:
  - \`i18n-key-prefix: info.outdated\` → structure: \`info: { outdated: { ... } }\`
  - \`i18n-key-prefix: info\` → structure: \`info: { ... }\`
  - \`i18n-key-prefix: difficulty\` → structure: \`difficulty: { ... }\`

---

### Inside components

- Replace any \`useTranslation()\` with:
  \`\`\`ts
  const { t } = useTranslation('<i18n-namespace>')
  \`\`\`

- Then call \`t('keyName')\`, not \`t('namespace.keyName')\`.

Correct:
\`\`\`ts
// If i18n-namespace is "components/common/exercise-widget"
const { t } = useTranslation('components/common/exercise-widget')
return <span>{t('solutionWasSolved')}</span>
\`\`\`

Wrong:
\`\`\`ts
const { t } = useTranslation()
return <span>{t('info.outdated.solutionWasSolved')}</span>
\`\`\`

Wrong:
\`\`\`ts
const { t } = useTranslation('info.outdated')
return <span>{t('solutionWasSolved')}</span>
\`\`\`

---

### Key naming rules

- Use **camelCase** for all keys.
- NEVER use raw UI strings as keys.
- NEVER include JSX/HTML markup in translation values.
- **Be conservative with variable creation:**
  - Only create variables (\`{{variableName}}\`) when the content is computed, transformed, or when multiple dynamic pieces need to be combined
  - Simple property access like \`{exercise.title}\` should usually stay in the component
  - Component slots: \`<componentName/>\`, or \`<componentName>{{value}}</componentName>\` for truly dynamic content
  
**When to use variables:**
- ✅ Computed values: \`{pluralize('iteration', count)}\` → \`{{pluralize}}\`
- ✅ Complex expressions: \`{formatDate(solution.createdAt)}\` → \`{{formattedDate}}\`
- ✅ When text and variables are tightly coupled: \`"in <trackIcon/> <trackTitle>{{trackTitle}}</trackTitle>"\`

**When NOT to use variables:**
- ❌ Simple property access: \`{exercise.title}\` → Keep in component
- ❌ Basic values that don't change the sentence structure

---

### Response format

Return your response in this format:

\`\`\`ts
// i18n
export default {
  info: {
    hasNotifications: "has notifications",
    trackLine: "in <trackIcon/> <trackTitle>{{trackTitle}}</trackTitle>",
    outdated: {
      solutionWasSolved: "This solution was solved against an older version of this exercise"
    }
  },
  difficulty: {
    easy: "Easy",
    medium: "Medium",
    hard: "Hard"
  }
}

// modified_files
// === file: ../components/common/exercise-widget/info/Outdated.tsx ===
... code ...
// === end file ===
\`\`\`

Remember: 
- NO JSX/HTML markup in translation values!
- Structure must reflect the namespace hierarchy!
- Only extract the actual text content!
- Use {{variables}} for dynamic content!
- Always use the full i18n-namespace in useTranslation calls!
`

  return `${instructions}

${fileSections}`
}

async function runLLM(prompt: string): Promise<string | undefined> {
  const ai = new GoogleGenAI({
    apiKey: '[censored]',
  })

  const response = await ai.models.generateContent({
    model: 'gemini-2.0-flash',
    contents: prompt,
    config: {},
  })

  return response.text
}

function parseLLMOutput(text: string): {
  translations: string
  files: Record<string, string>
} {
  // More flexible regex to capture the i18n export
  const i18nMatch = text.match(
    /\/\/ i18n[\s\S]*?export default\s*({[\s\S]*?})\s*(?:\/\/ modified_files|$)/
  )

  let translations = i18nMatch?.[1]?.trim() || '{}'

  // Clean up any trailing content after the closing brace
  const braceCount =
    (translations.match(/{/g) || []).length -
    (translations.match(/}/g) || []).length
  if (braceCount !== 0) {
    // Find the proper closing brace
    let openBraces = 0
    let endIndex = -1
    for (let i = 0; i < translations.length; i++) {
      if (translations[i] === '{') openBraces++
      if (translations[i] === '}') {
        openBraces--
        if (openBraces === 0) {
          endIndex = i
          break
        }
      }
    }
    if (endIndex !== -1) {
      translations = translations.substring(0, endIndex + 1)
    }
  }

  const fileSections = text.split(/\/\/ === file: (.*?) ===/g).slice(1)
  const files: Record<string, string> = {}

  for (let i = 0; i < fileSections.length; i += 2) {
    const filePath = fileSections[i]?.trim()
    const content = fileSections[i + 1]?.split('// === end file ===')[0]?.trim()
    if (filePath && content) {
      files[filePath] = content
    } else {
      console.warn(`Could not parse file section at index ${i}`)
    }
  }

  if (Object.keys(files).length === 0) {
    console.warn('No modified files were parsed from Gemini output.')
  }

  return {
    translations,
    files,
  }
}

async function writeRawLLMOutput(content: string, folder: string) {
  const normalizedPath = normalizePathForNamespace(folder)
  const safeName = normalizedPath.replace(/[\/\\]/g, '-')
  const outputDir = path.join('./en/debug')
  const filePath = path.join(outputDir, `${safeName}-llm-output.txt`)

  await fs.mkdir(outputDir, { recursive: true })
  await fs.writeFile(filePath, content, 'utf8')
}

async function writeTranslations(jsonString: string, folder: string) {
  const normalizedPath = normalizePathForNamespace(folder)
  const safeName = normalizedPath.replace(/[\/\\]/g, '-')
  const outputDir = path.join('./en/common')
  const filePath = path.join(outputDir, `${safeName}.ts`)

  await fs.mkdir(outputDir, { recursive: true })
  const content = `export default ${jsonString};\n`
  await fs.writeFile(filePath, content, 'utf8')
}

async function writeModifiedFiles(files: Record<string, string>) {
  for (const [filePath, content] of Object.entries(files)) {
    await fs.writeFile(filePath, content, 'utf8')
  }
}

// CLI Entrypoint
if (require.main === module) {
  const folder = process.argv[2]

  if (!folder) {
    console.error('Please provide a folder path.')
    process.exit(1)
  }

  readFilesInFolder(folder)
    .then(async (files) => {
      const prompt = buildPrompt(files, folder)
      const result = await runLLM(prompt)
      if (!result) {
        throw new Error('LLM returned no response')
      }
      await writeRawLLMOutput(result, folder)
      const parsed = parseLLMOutput(result)
      await writeTranslations(parsed.translations, folder)
      await writeModifiedFiles(parsed.files)
      console.log('i18n extraction and rewrite complete.')
      console.log(`Translation namespace: ${normalizePathForNamespace(folder)}`)
    })
    .catch((err) => {
      console.error('Error:', err)
      process.exit(1)
    })
}
