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

4. Use the \`i18n-namespace\` comment above each file for the \`useTranslation('<namespace>')\` call.
   - This ensures the correct namespace is passed to React-i18next and avoids collisions.
5. Replace all \`useTranslation()\` calls with \`useTranslation('<i18n-namespace>')\`.
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

### Inside components

Use:
\`\`\`ts
const { t } = useTranslation('<i18n-namespace>')
t('<i18n-key-prefix>.<key>')
\`\`\`

---

### Example of correct transformation

**Original:**
\`\`\`tsx
// i18n-key-prefix: info.outdated
// i18n-namespace: components/common/exercise-widget

const { t } = useTranslation()
return <Icon alt="This solution was solved against an older version of this exercise" />
\`\`\`

**Should become:**
\`\`\`tsx
const { t } = useTranslation('components/common/exercise-widget')
return <Icon alt={t('info.outdated.solutionWasSolved')} />
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
- Use the correct \`i18n-namespace\` for \`useTranslation()\`
`

  return `${instructions}\n\n${fileSections}`
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
  const outputDir = path.join('./en')
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
