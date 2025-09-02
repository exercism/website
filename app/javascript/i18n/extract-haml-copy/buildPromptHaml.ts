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
- VERY IMPORTANT!!!: The translation keys must be unique!!! 
e.g. if two sentences start the same way, like "Learn more about Ruby" and "Learn more about JavaScript", they should have different keys like \`learn_more_ruby\` and \`learn_more_javascript\`.
THEY SHOULD NOT BE LEARN_MORE 2 TIMES.
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

When converting \`pluralize(count, "word")\` into i18n, use Rails' pluralization format. Define the key in the YAML with both \`one\` and \`other\` forms, like this:

\`\`\`yaml
key_name:
  one: "1 word"
  other: "%{count} words"
\`\`\`

Then, in the HAML file, call the translation like this:

\`\`\`haml
= t('.key_name', count: count)
\`\`\`

For example, the following original code:

\`\`\`haml
\${pluralize count, 'issue'} need help
\`\`\`

Should be transformed into:

\`\`\`yaml
tasks_section:
  issues_needed_help:
    one: "1 issue needs help"
    other: "%{count} issues need help"
\`\`\`

And in HAML:

\`\`\`haml
= t('.issues_needed_help', count: count)
\`\`\`
This allows Rails to automatically handle singular and plural forms based on the count variable.


---

## VERY VERY Important: Preserve full sentences and phrases

Always keep complete sentences or coherent phrases in a **single translation key**, even if the HAML breaks the sentence across multiple tags for styling.

You may use **inline HTML tags** (like \`<strong>\`, \`<em>\`, etc.) inside the translation string. This ensures the sentence structure, punctuation, and word order are preserved — which is critical for correct translation in other languages.

### Example

Original HAML (styling split across elements):

\`\`\`haml
%h1.text-h0.mb-12
  Get
  %strong.leading-none.font-bold really
  good at programming.
%p.text-p-xlarge.mb-24
  Develop fluency in
  %em.not-italic.font-medium.text-textColor2 \#{@num_tracks} programming languages
  with our unique blend of learning, practice and mentoring.
  Exercism is fun, effective and
  %strong.text-textColor2 100% free, forever.
\`\`\`

Correct replacement using inline HTML and a single translation key:

\`\`\`haml
%h1.text-h0.mb-12
  = t('.header.title_html').html_safe

%p.text-p-xlarge.mb-24
  = t('.header.subtitle_html', num_tracks: @num_tracks).html_safe
\`\`\`

Corresponding YAML:

\`\`\`yaml
en:
  pages:
    index:
      header:
        title_html: "Get <strong>really</strong> good at programming."
        subtitle_html: >
          Develop fluency in <em>%{num_tracks} programming languages</em> with our unique
          blend of learning, practice and mentoring. Exercism is fun, effective and
          <strong>100% free, forever.</strong>
\`\`\`

VERY IMPORTANT!!!!!!!!!!!
If there is a link, use inline html and preserve full sentences! For example:


  Original HAML:  
   %p.text-p-base
     Start a new topic
     = link_to "in the forum", "https://forum.exercism.org/c/exercism/4"
     and let's discuss it.

  NEW HAML:
  %p.text-p-base= t('.tracks_section.add_language_description_html', forum_url: "https://forum.exercism.org/c/exercism/4").html_safe

  YML:
  add_language_description_html: >
    Start a new topic in the <a href="%{forum_url}">forum</a> and let's discuss it.



---

### Summary rule

- Do **not** split strings like individual words or fragments into separate keys.
- Keep full sentences or meaningful phrases together.
- Use inline HTML in your translation keys for styled parts, and call \`.html_safe\` when rendering them.
- This approach ensures translations are accurate, grammatical, and flexible for all languages.

---

Instead of HTML entities like \`&amp;\`, use the actual characters like \`&\` in your translations.

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
