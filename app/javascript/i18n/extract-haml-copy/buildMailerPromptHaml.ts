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

Your job is to **internationalize the user-facing copy** using Rails’ I18n system, saving all user-visible text as **Markdown blocks** in the YAML file. Prefer **one file → one key → one big Markdown block**.

---

## What to do

1. **Extract all user-facing text** (headings, paragraphs, button/link labels, placeholders, etc.).
   - Preserve full sentences/phrases.
   - When a sentence contains inline styles or links, merge them into a single **Markdown** string (\`**bold**\`, \`*italic*\`, \`[text](url)\`).

2. **Replace text in HAML**:
   - **HTML templates**: wrap with \`Markdown.parse(t('.body_markdown', vars...))\`
     \`= Markdown.parse(t('.body_markdown', vars...))\`
   - **TEXT templates**: plain \`= t('.body_markdown', vars...)\` (no parsing).
   - **Both HTML and TEXT must reference the SAME key** (single source of truth).

3. **Generate a YAML translation file**:
   - Must start with \`en:\`
   - Nest keys from the path **after** \`views/\` (use folder names; **ignore filenames**).
   - Store the extracted content as a **single block scalar** using \`|\`.

4. **CRITICAL RULE — one key per file (default)**:
   - Collapse the entire file into one single Markdown string (e.g. \`body_markdown\`).
   - Do **not** split into greeting/intro/outro/button text keys.
   - Only split if **absolutely unavoidable** (true pluralization, mutually exclusive branches, or content reused across unrelated emails).

5. **Buttons and links**
   - Do **NOT** create separate keys like \`button_text\`.
   - Represent buttons/links **inside the main Markdown** block as \`[label](%{url})\`.
   - Remove \`email_button_to "Label", url\` in HAML and rely on the Markdown link rendered by \`Markdown.parse\`.

6. **YAML Scalar Safety (avoid "Unexpected scalar at node end")**
   - Use a **block scalar**: \`key: |\\n  <content>\`
   - **Indent every line** of the Markdown content by **at least two spaces** relative to the key.
   - **Never outdent** within the block; the block ends only when a **new key** at the same indentation as the key appears.
   - **Always include a final newline** at the end of the block scalar.
   - **Lists**: When emitting Markdown lists (\`- item\`, \`1. item\`), **insert a blank line before the list**, and keep list lines at the **same indentation** as the rest of the block content.
   - **No stray lines after the block**: Do not emit any unindented text after the YAML block; any additional content must be part of the same block (properly indented) or a **new key**.
   - **Spaces only** (no tabs).

   **Correct (note indentation & blank line before list):**
   \`\`\`yaml
   body_markdown: |
     Hey!

     I'm excited to let you know you're eligible...

     Insiders gives you a few extra benefits:

     1. Access to our Dark Mode
     2. ChatGPT Integration

     [See the feedback](%{feedback_url})
   \`\`\`

   **Incorrect (leaks a stray scalar / dedents inside block):**
   \`\`\`yaml
   body_markdown: |
     Hey!
   [See the feedback](%{feedback_url})   # ❌ dedented, outside block
   \`\`\`

7. **Pluralization**
   - If true pluralization is required, use Rails plural forms under one key:
     \`\`\`yaml
     items_count:
       one: "1 item"
       other: "%{count} items"
     \`\`\`
   - In HAML: \`= Markdown.parse(t('.items_count', count: count))\`
   - Keep any surrounding sentence in the same Markdown key **when practical**.

---

## Example (HTML + TEXT mailer pair)

**Original**

\`\`\`haml
# views/mailers/notifications_mailer/student_timed_out_discussion_student.text.haml
Hi \#{@user.handle},
New feedback has been added to iteration (\#\#{@iteration.idx})...
Go to the iteration: \#{track_exercise_iterations_url(@track, @exercise)}
\`\`\`

\`\`\`haml
# views/mailers/notifications_mailer/student_timed_out_discussion_student.html.haml
%p Hi \#{@user.handle},
%p New feedback has been added to iteration (\#\#{@iteration.idx})...
= email_button_to "See the feedback", track_exercise_iterations_url(@track, @exercise)
\`\`\`

**Modified HAML**

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

**YAML**

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
