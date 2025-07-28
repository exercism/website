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
    
    Your task is to extract **all user-visible strings** and return a flat JSON object that maps translation keys to their corresponding full-text values.
    
    ---
    
    ## ✅ What counts as a user-visible string?
    
    You must extract **every** static string that will appear to the user in the UI, including but not limited to:
    
    - Text in HAML tags (e.g., \`%h1 Welcome!\`, \`%p.text-body Hello there\`)
    - Strings in \`link_to\`, \`button_to\`, \`content_tag\`, \`submit_tag\`, \`label_tag\`, etc.
    - Inline text after tags (e.g., \`.label Some visible text\`)
    - Text inside blocks (e.g., \`= link_to do ... 'Back to All Jobs'\`)
    - Attribute values like \`placeholder: 'Enter name'\`, \`title: 'Tooltip text'\`
    - Strings with interpolation: \`"Hello \#{user.name}"\` → \`"Hello %{user_name}"\`
    
    Do NOT extract:
    - Class names, IDs, or internal logic
    - Ruby code that does not produce visible text
    - Comments
    
    ---
    
    ## Extract full logical blocks as one string
    
    When multiple lines form a single cohesive message or paragraph, **combine them into a single translation**.
    
    Extract them as a single key **even if they span multiple lines or use inline tags like \`%strong\`**.
    
    Example block (HAML):
    
    \`\`\`haml
    %p.text-large
      %strong Become Exercism's new Rails developer!
      We're looking for someone who loves working with Ruby and Rails.
      Do you enjoy building well-architected, readable Rails code?
      If so, this role might be perfect for you.
    \`\`\`
    
    Extracted translation:
    
    \`\`\`json
    {
      "hiringRailsDeveloper.intro": "Become Exercism's new Rails developer! We're looking for someone who loves working with Ruby and Rails. Do you enjoy building well-architected, readable Rails code? If so, this role might be perfect for you."
    }
    \`\`\`
    
    Another example with interpolation:
    
    \`\`\`haml
    %p.text-body
      Learn more on our \#{link_to 'About Exercism', 'https://exercism.org/about'}.
    \`\`\`
    
    Extracted translation:
    
    \`\`\`json
    {
      "hiringRailsDeveloper.learnMore": "Learn more on our %{about_exercism_link}."
    }
    \`\`\`
    
    And also extract:
    
    \`\`\`json
    {
      "hiringRailsDeveloper.aboutExercismLink": "About Exercism"
    }
    \`\`\`
    
    ---
    
    ## Interpolation and pluralization
    
    - Interpolations like \`Hello \#{user.name}\` → \`Hello %{user_name}\` (snake_case)
    - For counts: provide \`_one\` and \`_other\` keys  
      - Example: \`"1 comment"\` / \`"%{count} comments"\`
    
    ---
    
    ## Key format
    
    - Use the given \`i18n-key-prefix\` (e.g., \`hiringRailsDeveloper\`)
    - Use only lowercase dot-separated words
    - No nested JSON (output must be flat)
    - Do not use numbers, symbols, or camelCase
    
    Good keys:
    
    - \`hiringRailsDeveloper.title\`
    - \`hiringRailsDeveloper.summary.aboutExercismLink\`
    - \`notifications.count_one\`, \`notifications.count_other\`
    
    ---
    
    ## Output format
    
    Output must be:
    
    - **A single flat JSON object**
    - **Double-quoted keys and values**
    - **No nesting**
    - **No code blocks**
    - **No explanations or comments**
    - **No trailing commas**
    
    Correct:
    
    {
      "hiringRailsDeveloper.summary": "Our platform is centred around self-directed learning and mentoring.",
      "hiringRailsDeveloper.linkLabel": "About Exercism"
    }
    
    Incorrect (nested):
    
    {
      "hiringRailsDeveloper": {
        "summary": "..."
      }
    }
    
    ---
    `

  return `${instructions}\n\n${fileSections}`
}
