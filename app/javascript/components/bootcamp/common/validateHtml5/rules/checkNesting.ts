import { isVoidElement } from '../voidElements'

export function checkNesting(html: string): void {
  const tagRegex = /<\/?([a-zA-Z][a-zA-Z0-9-]*)\b[^>]*?>/g
  const tagStack: string[] = []

  let match
  while ((match = tagRegex.exec(html)) !== null) {
    const fullMatch = match[0]
    const tagName = match[1]

    const isClosing = fullMatch.startsWith('</')

    if (isClosing) {
      const lastOpen = tagStack.pop()
      if (!lastOpen) {
        throw new Error(`Extra closing tag: </${tagName}>`)
      }
      if (lastOpen !== tagName) {
        throw new Error(
          `Mismatched tags: <${lastOpen}> closed by </${tagName}>`
        )
      }
    } else if (!isVoidElement(tagName)) {
      tagStack.push(tagName)
    }
  }

  if (tagStack.length > 0) {
    throw new Error(`Unclosed tag(s): ${tagStack.join(', ')}`)
  }
}
