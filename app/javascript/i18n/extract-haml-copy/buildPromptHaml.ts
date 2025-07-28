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
    
    Your task is to extract **all user-visible strings** and generate a JSON object mapping translation keys to their corresponding text.
    
    ---
    
    ## What counts as a user-visible string?
    
    Extract all static text that would be shown to an end user in the browser. This includes:
    
    - Text after HAML tags (e.g., \`%h1 Welcome!\`)
    - Strings in Ruby helpers like:
      - \`link_to 'Dashboard', ...\`
      - \`button_to 'Click me', ...\`
      - \`content_tag :p, 'Some text'\`
      - \`form_for ... do |f| ... f.label 'Email' ... f.submit 'Send'\`
    - Text in attributes (e.g., \`placeholder: 'Enter name'\`, \`title: 'Tooltip text'\`)
    - Strings used in conditionals that would be rendered (e.g. \`= flash[:notice]\`)
    - Interpolated strings like \`"Hello #{user.name}"\`, which should become \`"Hello %{user_name}"\`
    
    Do **NOT** extract:
    - Class or id names
    - Internal Ruby code or logic
    - Dynamic values (e.g., variables or method calls without static text)
    
    ---
    
    ## Extract full logical blocks as one string
    
    If multiple lines together form a single user-visible paragraph or unit of thought, extract them as a **single translation value**, even if the text spans multiple lines or is split by interpolation.
    
    Group them when:
    - They are part of a longer message or paragraph
    - They appear consecutively within the same indentation level
    - They form one cohesive block a user would read as a whole
    
    Good example (should be extracted as **one translation**):
    
    \`\`\`haml
    = t('hiringContent.summary.paragraph1')
    Our online platform is centred around self-directed learning and volunteer mentoring, and has nearly one million members.
    Over the next 5 years, we want to become the defacto programming education platform that anyone, anywhere can use for free.
    Through our work we aim to improve the global standard of programming and increase participation in tech from under-represented groups.
    You can learn more about Exercism in our #{link_to 't("hiringContent.summary.aboutExercismPagesLinkText")', 'https://exercism.org/about'}
    \`\`\`
    
    Extract this entire block as:
    
    \`\`\`json
    {
      "hiringContent.summary.paragraph1": "Our online platform is centred around self-directed learning and volunteer mentoring, and has nearly one million members. Over the next 5 years, we want to become the defacto programming education platform that anyone, anywhere can use for free. Through our work we aim to improve the global standard of programming and increase participation in tech from under-represented groups. You can learn more about Exercism in our %{about_exercism_pages_link_text}."
    }
    \`\`\`
    
    Make sure to replace embedded calls like \`#{link_to ...}\` with placeholders such as \`%{about_exercism_pages_link_text}\` and generate a separate key for the embedded link text:
    
    \`\`\`json
    {
      "hiringContent.summary.aboutExercismPagesLinkText": "About Exercism pages"
    }
    \`\`\`
    
    Do **not** split each sentence into separate keys.  
    Do **not** exclude follow-up sentences that belong to the same logical block.
    
    ---
    
    ## For interpolated or pluralized text:
    
    - Replace interpolations like \`#{user.name}\` with \`%{user_name}\` (snake_case)
    - For pluralization, create both \`_one\` and \`_other\` variants if the string includes a count (e.g. \`"1 comment"\`, \`"%{count} comments"\`)
    
    ---
    
    ## Translation keys format
    
    - Use the provided \`i18n-key-prefix\` (e.g., \`adminDashboard\`) as a base
    - Generate readable and descriptive keys
    - Use dot-separated lowercase words
    - Allowed suffixes: \`_one\`, \`_other\`
    - Do not use underscores (except for _one/_other), numbers, or special characters
    
    Examples:
    
    - \`adminDashboard.title\`: "Admin Dashboard"
    - \`userForm.placeholderName\`: "Enter your name"
    - \`notifications.commentCount_one\`: "1 comment"
    - \`notifications.commentCount_other\`: "%{count} comments"
    
    ---
    
    ## Output format:
    
    Output **ONLY** a single valid JSON object, with all extracted key-value pairs.
    
    NO code blocks, NO explanations, NO extra text. Use **double quotes** and **no trailing commas**.
    
    ---
    `

  return `${instructions}\n\n${fileSections}`
}
