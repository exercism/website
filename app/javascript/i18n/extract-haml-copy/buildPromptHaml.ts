import path from 'path'

export function buildPrompt(
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

Your job is to fully internationalize the user-facing copy using Rails’ I18n system.

---

## What to do

1. Extract all user-visible text (headings, paragraphs, button/link labels, placeholders, etc.).
2. Replace the text in the HAML using \`= t('.nested.key') \` or \` = t('.nested.key', var: ...) \`.
3. Generate a **YAML translation file** using the file path for namespacing.

---

## Key nesting and path logic

Use the Rails convention where:

- The YAML must start with \`en: \`
- The translation keys are nested based on the **path after \`views /\`**, using folder names and then dot-separated keys.
- File names **should be ignored** in the YAML key hierarchy.

Example:

Given a file at:

\`\`\`
views/tracks/show/_summary_article.html.haml
\`\`\`

and a line like:

\`\`\`haml
%h2 You've just started the %{track_title} track.
\`\`\`

You must:

1. Replace the line with:

\`\`\`haml
%h2= t('.progress_chart.title.just_started', track_title: track.title)
\`\`\`

2. And generate YAML like:

\`\`\`yaml
en:
  tracks:
    show:
      summary_article:
        progress_chart:
          title:
            just_started: "You've just started the %{track_title} track."
\`\`\`

---

## HAML replacement rules

- Replace \`% p Hello\` with \` % p= t('.key') \`
- Replace multi-line blocks with a single-line \`t() \` call
- Replace \`"\#{user.name}"\` with \` % { user_name }\` and pass it as a named variable
- Use \`t('.key', variable: ...) \` syntax when interpolating
- For \`link_to\` or \`button_to\`, move the string into \`t() \`

---

## Output format

You must return exactly two parts in the following order:

1. The modified HAML files, each introduced by:
   \`# file: path / to / file.html.haml\`
2. Then one YAML block starting with \`en: \`, properly nested.

No explanations. No code blocks. No commentary.

---

Now return the modified HAML followed by a single YAML block with all the translations.
`.trim()

  return `${instructions}\n\n${fileSections}`
}
