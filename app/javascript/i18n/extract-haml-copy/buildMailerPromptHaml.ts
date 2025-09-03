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
You are given one or more Ruby on Rails view files written in HAML (under "views/…").

Your job: **internationalize all user-facing copy** with Rails I18n, saving it as **Markdown** in YAML. **One file → one key → one big Markdown block**.

---

## What to do

1) **Extract user-visible text** (headings, paragraphs, labels, placeholders, etc.). Keep **full sentences/phrases**. Merge styled/linked fragments into a single **Markdown** string (\`**bold**\`, \`*italic*\`, \`[text](url)\`).

2) **Replace text in HAML**:
   - **HTML templates** → \`= Markdown.parse(t('.body_markdown', vars...))\`
   - **TEXT templates** → \`= t('.body_markdown', vars...)\` (no parsing)
   - **HTML+TEXT pair must reference the SAME key** (\`.body_markdown\`).

3) **Generate YAML**:
   - Must start with \`en:\`
   - Keys nest from the path **after** \`views/\` using folder names (**ignore filenames**).
   - Store content as a **single block scalar** using \`|\` under the key \`body_markdown\`.

4) **CRITICAL — one key per file/pair (default)**:
   - Collapse the entire body into **one** key: \`body_markdown\`.
   - Do **NOT** split into greeting/intro/outro/button/cta keys.
   - Only split if **truly unavoidable** (real pluralization or mutually exclusive branches). Otherwise, one key is mandatory.

5) **Buttons & links**
   - Do **NOT** create keys like \`button_text\`.
   - Represent buttons/CTAs as Markdown links **inside** \`body_markdown\`: \`[Label](%{url})\`.
   - Remove \`email_button_to "Label", url\` and rely on the Markdown link rendered by \`Markdown.parse\`.

6) **Complex styling (IMPORTANT)**
   - **Do not change or simplify the styling.**
   - If an element has inline styles, complex layout, or requires attributes (e.g. thumbnail images, styled anchors), **preserve the original HTML directly inside the Markdown block**.
   - Example:
     \`\`\`markdown
     <p style="margin-bottom: 24px">
       <a href="%{youtube_video_url}" style="display:block; box-shadow: 0px 2px 4px #0F0923">
         <img src="%{youtube_thumbnail_url}" style="width:100%; display:block" />
       </a>
     </p>
     \`\`\`

7) **YAML Scalar Safety (no stray scalars)**
   - Use a block scalar: \`key: |\\n  <content>\`
   - **Every single line** inside the block must start with **at least two spaces** relative to the key.
   - **Never outdent** inside the block; the block ends only when a **new key** appears at the key’s indentation.
   - **Always end the block with a newline**.
   - **Lists**: Insert a **blank line before** any Markdown list (\`- item\`, \`1. item\`), and keep list items at the **same 2-space indent** as the rest of the block.
   - **After a list, keep subsequent paragraphs at the same indent** (still inside the block).
   - **No lines at column 1** after starting the block unless you are starting a new YAML key.

   **Correct (note blank line before list and concluding line still indented):**
   \`\`\`yaml
   body_markdown: |
     Hey!

     Intro paragraph.

     Here are the benefits:

     1. First
     2. Second

     We hope you enjoy this!
   \`\`\`

   **Incorrect (concluding line leaked outside the block — starts at column 1):**
   \`\`\`yaml
   body_markdown: |
     Hey!

     Here are the benefits:

     1. First
     2. Second
   We hope you enjoy this!   # ❌ dedented, outside the block
   \`\`\`

8) **Pluralization (only if needed)**
   - Use Rails forms under **one** pluralization key, keeping surrounding prose together when practical:
     \`\`\`yaml
     things_count:
       one: "1 thing"
       other: "%{count} things"
     \`\`\`
     HAML: \`= Markdown.parse(t('.things_count', count: count))\`

  MOST IMPORTANT: NEVER CHANGE CONTENT! NEVER! NEVER CHANGE BUTTON TEXT!!!!!!!!

---

## Example (HTML + TEXT pair)

**Modified HAML**
\`\`\`haml
/ text.haml
= t('.body_markdown',
  user_handle: @user.handle,
  feedback_url: track_exercise_iterations_url(@track, @exercise)
)

/ html.haml
= Markdown.parse(
    t('.body_markdown',
      user_handle: @user.handle,
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

          New feedback has been added to your iteration.

          [See the feedback](%{feedback_url})
\`\`\`

---

## Output format (strict)

1) List the **modified HAML files**, each introduced by:
   \`# file: path/to/file.html.haml\`
2) Then output **one** YAML block starting with \`en:\`.

**Hard checks before you output** (must all be true):
- Exactly **one** translation key per file/HTML+TEXT pair: \`body_markdown\`.
- Inside every \`|\` block, **every line** begins with **≥ 2 spaces**.
- If you include a list, there is a **blank line before it**, and any **concluding paragraph is still indented** (inside the block).
- The block scalar **ends with a newline** and there are **no stray lines** at column 1 after it.
- You must not rewrite or simplify the content.  
- Where inline styling or HTML structure is present, preserve it **verbatim inside the Markdown block**.

No explanations. No extra commentary.

---
`.trim()

  return `${instructions}\n\n${fileSections}`
}
