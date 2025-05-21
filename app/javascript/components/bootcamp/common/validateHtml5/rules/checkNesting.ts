import { isVoidElement } from '../voidElements'

export function checkNesting(html: string): void {
  const tags: Array<{ type: 'open' | 'close'; name: string; pos: number }> = []

  const openTagRegex = /<([a-zA-Z][a-zA-Z0-9-]*)\b[^>]*?>/g
  const closeTagRegex = /<\/([a-zA-Z][a-zA-Z0-9-]*)\s*>/g

  let match
  while ((match = openTagRegex.exec(html)) !== null) {
    const tagName = match[1]
    if (!isVoidElement(tagName)) {
      tags.push({ type: 'open', name: tagName, pos: match.index })
    }
  }

  while ((match = closeTagRegex.exec(html)) !== null) {
    tags.push({ type: 'close', name: match[1], pos: match.index })
  }

  tags.sort((a, b) => a.pos - b.pos)

  const tagStack: string[] = []
  for (const tag of tags) {
    if (tag.type === 'open') {
      tagStack.push(tag.name)
    } else {
      const last = tagStack.pop()
      if (!last) {
        throw new Error(`Extra closing tag: </${tag.name}>`)
      }
      if (last !== tag.name) {
        throw new Error(`Mismatched tags: <${last}> closed by </${tag.name}>`)
      }
    }
  }

  if (tagStack.length > 0) {
    throw new Error(`Unclosed tag(s): ${tagStack.join(', ')}`)
  }
}
