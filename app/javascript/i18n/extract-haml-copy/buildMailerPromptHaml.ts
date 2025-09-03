import path from 'path'

export function buildMailerPrompt(
  files: Record<string, string>,
  rootFolder: string
): string {
  const fileSections = Object.entries(files)
    .map(([filePath, content]) => {
      return `# file: ${filePath}
${content}
# end file`
    })
    .join('\n\n')

  const instructions = `
You are given one or more Ruby on Rails view files written in HAML, along with their full file paths (starting from the "views/" directory).

Your job is to **internationalize the user-facing copy** using Rails’ I18n system, saving all user-visible text as **Markdown blocks** in the YAML file.

---

## What to do

1. **Extract all user-facing text** (headings, paragraphs, button/link labels, placeholders, etc.).  
   - Always preserve full sentences or phrases.  
   - When a sentence contains inline styles (\`%strong\`, \`%em\`) or links (\`link_to\`), merge them into a single Markdown string.  
   - Use Markdown formatting (\`**bold**\`, \`*italic*\`, \`[link text](url)\`) inside the translation string.  

2. **Replace the text in the HAML** with calls to \`Markdown.parse(t('.nested.key', var: ...))\`.  
   - Always wrap translation calls in \`Markdown.parse(...)\`.  
   - Use interpolation variables (\`%{var}\`) for dynamic content.  

3. **Generate a YAML translation file**:  
   - Must start with \`en:\`  
   - Nest keys based on the path after \`views/\`, using folder names, then dot-separated keys.  
   - **Ignore filenames** when building YAML hierarchy.  
   - Store each extracted string as a **Markdown block** (\`|\` for multi-line).  
   - **When including Markdown lists inside YAML (like \`- item\` or \`1. item\`), ALWAYS insert a blank line before the list.**  
     This ensures YAML parsers don’t misinterpret list markers as YAML structure. 

4. **CRITICAL RULE — one key per file**  
   - The **entire file’s content should be collapsed into one single Markdown string**.  
   - The modified HAML should normally contain **only one call**:  
     \`= Markdown.parse(t('.some_key', vars...))\`.  
   - Do **not** split into greeting, intro, outro, buttons, etc. — those must all stay inside the same Markdown block.  
   - Use inline Markdown links or bold text to keep everything in one key.  
   - Only split into multiple keys if **absolutely unavoidable** (e.g. pluralization, dynamic conditionals, or reusable buttons across multiple emails).  

---

## Example

Original HAML:
\`\`\`haml
%p Hi \#{@user.handle},
%p Thank you for your donation!
%p
  You can view your receipts here:
  = link_to "Settings", donations_settings_url
\`\`\`

Modified HAML:
\`\`\`haml
= Markdown.parse(t('.body_text_markdown', user_handle: @user.handle, donations_settings_url: donations_settings_url))
\`\`\`

YAML:
\`\`\`yaml
en:
  mailers:
    donations_mailer:
      payment_created:
        body_text_markdown: |
          Hi %{user_handle},

          Thank you for your donation!

          You can view your receipts in your [Settings](%{donations_settings_url}) page.
\`\`\`

---

## Summary Rules

- Always use Markdown (not inline HTML) inside translation strings.  
- **Default rule: one file = one key = one big Markdown block.**  
- Inline Markdown (links, bold, italics, lists) is preferred over splitting into multiple keys.  
- Always render with \`Markdown.parse(t(...))\` in HAML.  
- **Always insert a blank line before Markdown lists in YAML.**  
- Ensure all keys are unique.  

---

## Output format

Return exactly two parts in this order:

1. The modified HAML files, each introduced by:
   \`# file: path/to/file.html.haml\`
2. Then one YAML block starting with \`en:\`, containing all extracted Markdown translations.

No explanations. No extra commentary.

---

`.trim()

  return `${instructions}\n\n${fileSections}`
}
