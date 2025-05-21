export function checkOpeningTagTermination(html: string): void {
  const tagOpenRegex = /<([a-zA-Z][a-zA-Z0-9-]*)\b[^<>]*$/gm

  let match
  while ((match = tagOpenRegex.exec(html)) !== null) {
    const tagStart = match.index
    const nextGt = html.indexOf('>', tagStart)
    const nextLt = html.indexOf('<', tagStart + 1)

    // if there is no closing > or another < comes before it, it's unclosed
    if (nextGt === -1 || (nextLt !== -1 && nextLt < nextGt)) {
      const partial = html.slice(tagStart, nextLt !== -1 ? nextLt : undefined)
      throw new Error(`Unterminated opening tag: ${partial.trim()}`)
    }
  }

  // if the last < is after the last >, it's an unclosed tag
  const lastOpen = html.lastIndexOf('<')
  const lastClose = html.lastIndexOf('>')
  if (lastOpen > lastClose) {
    const partial = html.slice(lastOpen).trim()
    throw new Error(`Unclosed tag at end of document: ${partial}`)
  }
}
