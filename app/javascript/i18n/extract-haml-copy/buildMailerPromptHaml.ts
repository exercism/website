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

2. **Replace the text in the HAML** with calls to translations:  
   - In **HTML templates**, wrap in \`Markdown.parse(...)\` like this:  
     \`= Markdown.parse(t('.body_markdown', vars...))\`  
   - In **TEXT templates**, just call \`= t('.body_markdown', vars...)\` (no parsing).  
   - Both must point to the **same translation key**.  

3. **Generate a YAML translation file**:  
   - Must start with \`en:\`  
   - Nest keys based on the path after \`views/\`, using folder names, then dot-separated keys.  
   - **Ignore filenames** when building YAML hierarchy.  
   - Store each extracted string as a **Markdown block** (\`|\` for multi-line).  
   - **When there is both a \`*.text.haml\` and \`*.html.haml\` file with the same content, extract only ONE Markdown key** and reuse it in both files.  

4. **CRITICAL RULE — one key per file**  
   - The **entire file’s content should be collapsed into one single Markdown string**.  
   - Do **not** split into greeting, intro, outro, buttons, etc. — those must all stay inside the same Markdown block.  
   - Use inline Markdown links or bold text to keep everything in one key.  
   - Only split into multiple keys if **absolutely unavoidable** (e.g. pluralization, dynamic conditionals, or reusable buttons across multiple unrelated emails).  

5. **YAML list safety**  
   - If the Markdown contains a list (numbered or bulleted), **always insert a blank line before the list** so it parses correctly as YAML.  
  6. **Buttons and links**
   - Do NOT create a separate YAML key for button labels (e.g. \`button_text\`).
   - All buttons or links must be represented inside the main Markdown block as \`[link text](%{url})\`.
   - In the HAML, remove \`email_button_to "Text", url\` and instead rely on \`Markdown.parse(t(...))\` rendering the Markdown link.
   - Example:

     Original HAML:
     \`\`\`haml
     = email_button_to "See the feedback", track_exercise_iterations_url(@track, @exercise)
     \`\`\`

     Modified HAML:
     \`\`\`haml
     = Markdown.parse(t('.body_markdown', feedback_url: track_exercise_iterations_url(@track, @exercise)))
     \`\`\`

     YAML:
     \`\`\`yaml
     body_markdown: |
       [See the feedback](%{feedback_url})
     \`\`\`

---

## Example (HTML + TEXT mailer pair)

Original files:

\`\`\`haml
# views/mailers/notifications_mailer/student_timed_out_discussion_student.text.haml
Hi \#{@user.handle},
New feedback has been added to iteration (\#\#{@iteration.idx}) of your solution to \#{@exercise.title} on the \#{@track.title} track.
Go to the iteration: \#{track_exercise_iterations_url(@track, @exercise)}
\`\`\`

\`\`\`haml
# views/mailers/notifications_mailer/student_timed_out_discussion_student.html.haml
%p Hi \#{@user.handle},
%p New feedback has been added to iteration (\#\#{@iteration.idx}) of your solution to \#{@exercise.title} on the \#{@track.title} track.
= email_button_to "See the feedback", track_exercise_iterations_url(@track, @exercise)
\`\`\`

Modified HAML:

\`\`\`haml
# text.haml
= t('.body_markdown',
  user_handle: @user.handle,
  iteration_idx: @iteration.idx,
  exercise_title: @exercise.title,
  track_title: @track.title,
  feedback_url: track_exercise_iterations_url(@track, @exercise)
)

# html.haml
= Markdown.parse(
    t('.body_markdown',
      user_handle: @user.handle,
      iteration_idx: @iteration.idx,
      exercise_title: @exercise.title,
      track_title: @track.title,
      feedback_url: track_exercise_iterations_url(@track, @exercise)
    )
  )
\`\`\`

YAML:

\`\`\`yaml
en:
  mailers:
    notifications_mailer:
      student_timed_out_discussion_student:
        body_markdown: |
          Hi %{user_handle},

          New feedback has been added to iteration (%{iteration_idx}) of your solution to %{exercise_title} on the %{track_title} track.

          [See the feedback](%{feedback_url})
\`\`\`

---

## Summary Rules

- Always use Markdown (not inline HTML) inside translation strings.  
- **Default rule: one file = one key = one big Markdown block.**  
- When both HTML + TEXT versions exist, **reuse the same Markdown key**.  
- HTML uses \`Markdown.parse(t(...))\`, TEXT uses \`t(...)\`.  
- Always insert a blank line before Markdown lists in YAML.  
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
