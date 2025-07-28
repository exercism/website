import path from 'path'
import { toCamelCase } from '../extract-jsx-copy/toCamelCase'
import { normalizePathForNamespace } from '../extract-jsx-copy/normalizePathForNamespace'

export function buildPrompt(
  files: Record<string, string>,
  rootFolder: string
): string {
  const namespace = normalizePathForNamespace(rootFolder)
  const fileSections = Object.entries(files)
    .map(([filePath, content]) => {
      const relativePath = path.relative(rootFolder, filePath)
      const withoutExt = relativePath.replace(/\.html\.haml$/, '')
      const parts = withoutExt.split(path.sep)
      const camelParts = parts.map(toCamelCase)
      const keyPrefix = camelParts.join('.')
      return `# file: ${filePath}
-# i18n-key-prefix: ${keyPrefix}
${content}
# end file`
    })
    .join('\n\n')

  const instructions = `
    You are given one or more Ruby on Rails view files written in HAML.
    
    Your task is to extract **all user-visible text** and return a **flat JSON object** mapping translation keys to the full strings.
    
    ---
    
    ## ✅ What to extract
    
    You must extract **every string that is shown to users in the browser**, including:
    
    - Text in HAML tags (e.g. \`%h1 Welcome!\`, \`%p.text Hello\`)
    - Inline text after tags (e.g. \`.label Some label\`)
    - Strings in Ruby helpers like:
      - \`link_to 'Click here', ...\`
      - \`button_to 'Submit'\`
      - \`content_tag :p, 'Some text'\`
    - Strings inside attribute hashes:
      - \`placeholder: 'Enter your email'\`
      - \`title: 'Click to expand'\`
    - Strings from interpolated Ruby expressions like:
      - \`"Hello \#{user.name}"\` → \`"Hello %{user_name}"\`
    - \`content_for\` calls that set meta titles or descriptions
    
    ---
    
    ## 🧩 Group full paragraphs and sections
    
    If a section contains **multiple lines of user-visible text that form a cohesive paragraph or block**, you **must group it into a single translation**.
    
    This includes:
    
    - Paragraphs split across multiple HAML lines
    - Inline tags (e.g. \`%strong\`, \`%em\`) that wrap part of a sentence
    - Consecutive lines that are read together (e.g. in job listings, descriptions)
    
    ✅ Example:
    
    \`\`\`haml
    %p
      %strong Join Exercism!
      We’re looking for someone to help us grow.
      If that’s you, we’d love to hear from you!
    \`\`\`
    
    → Output:
    
    \`\`\`json
    {
      "hiringContent.intro": "Join Exercism! We’re looking for someone to help us grow. If that’s you, we’d love to hear from you!"
    }
    \`\`\`
    
    ---
    
    ## 🔗 Interpolation and inline links
    
    Replace \`\#{...}\` Ruby interpolation with **named placeholders** like \`%{link_text}\`.
    
    Also extract the visible text inside the interpolation separately.
    
    ✅ Example:
    
    \`\`\`haml
    %p Learn more at \#{link_to 'About Exercism', 'https://exercism.org/about'}
    \`\`\`
    
    → Output:
    
    \`\`\`json
    {
      "hiringContent.learnMore": "Learn more at %{about_exercism_link}",
      "hiringContent.aboutExercismLink": "About Exercism"
    }
    \`\`\`
    
    ---
    
    ## 🔢 Pluralization
    
    If a string depends on a numeric value, provide two keys using \`_one\` and \`_other\`.
    
    ✅ Example:
    
    \`\`\`haml
    = "\#{count} applicants"
    \`\`\`
    
    → Output:
    
    \`\`\`json
    {
      "hiringContent.applicants_one": "%{count} applicant",
      "hiringContent.applicants_other": "%{count} applicants"
    }
    \`\`\`
    
    ---
    
    ## ❌ DO NOT extract:
    
    - CSS classes or HTML tag names
    - Ruby logic (unless it produces visible strings)
    - Any comments or helper method names
    
    ---
    
    ## 🗝️ Key format
    
    - Use the given \`i18n-key-prefix\` (e.g., \`hiringContent\`)
    - All keys must be flat, dot-separated strings
    - Keys must be lowercase, using dot.notation
    - NEVER nest keys
    - NEVER use camelCase
    - Use descriptive key suffixes like \`intro\`, \`summary.vision\`, \`apply.instructions\`
    
    ---
    
    ## ✅ Output format
    
    Return ONLY:
    
    - One flat JSON object
    - Double-quoted keys and values
    - No trailing commas
    - No nested objects
    - No code blocks, no explanations
    
    ✅ Correct:
    
    \`\`\`json
    {
      "hiringContent.title": "Educational Content Creator",
      "hiringContent.summary": "We're looking for someone to help build a world-class platform."
    }
    \`\`\`
    
    ❌ Incorrect:
    
    \`\`\`json
    {
      "hiringContent": {
        "title": "Educational Content Creator"
      }
    }
    \`\`\`
    
    ❌ Also wrong:
    
    - Using backticks/code blocks
    - Including prose or commentary
    
    ---
    
    Now perform the extraction.
    `

  return `${instructions}\n\n${fileSections}`
}
