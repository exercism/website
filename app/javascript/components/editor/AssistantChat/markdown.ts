import { marked } from 'marked'

const HTML_ESCAPES: Record<string, string> = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;',
}

function escapeHtml(text: string): string {
  return text.replace(/[&<>"']/g, (char) => HTML_ESCAPES[char])
}

// Assistant content is model output relayed by the proxy, so it is untrusted.
// marked passes raw HTML through by default, which would let a crafted response
// inject markup into the editor. Overriding the block and inline `html`
// renderers to escape their source neutralises that while leaving every other
// markdown feature (including blockquotes and autolinks, which a naive
// pre-escape of `<`/`>` would break) working normally.
const renderer = {
  html({ text }: { text: string }): string {
    return escapeHtml(text)
  },
}

marked.use({ gfm: true, breaks: true, renderer })

export function renderMarkdown(content: string): string {
  return marked.parse(content, { async: false }) as string
}
