import { isVoidElement } from '../voidElements'

export function checkVoidTagClosure(html: string): void {
  // A more precise regex to find all potential tag openings
  const tagRegex = /<([a-zA-Z][a-zA-Z0-9-]*)((?:\s+[^<>]*?)?)(\s*\/?\s*)>?/g

  let match
  let lastIndex = 0

  while ((match = tagRegex.exec(html)) !== null) {
    const fullMatch = match[0]
    const tagName = match[1]
    const attributes = match[2] || ''
    const endPart = match[3] || ''
    const startIndex = match.index

    // Check if this tag ends with a proper closing bracket
    if (!fullMatch.endsWith('>')) {
      // Make sure we're not just matching part of another tag's attribute
      const nextBracket = html.indexOf('>', startIndex)
      const nextOpenBracket = html.indexOf('<', startIndex + 1)

      // If we have another opening bracket before a closing one, this is an unclosed tag
      if (
        nextBracket === -1 ||
        (nextOpenBracket !== -1 && nextOpenBracket < nextBracket)
      ) {
        throw new Error(
          `Tag <${tagName}${attributes}${endPart} is not properly closed with '>'`
        )
      }
    }

    lastIndex = tagRegex.lastIndex
  }

  // Now specifically check void elements for proper closure
  const voidTagRegex = /<([a-zA-Z][a-zA-Z0-9-]*)((?:\s+[^<>]*?)?)(\s*\/?\s*)>?/g

  while ((match = voidTagRegex.exec(html)) !== null) {
    const fullMatch = match[0]
    const tagName = match[1]
    const attributes = match[2] || ''
    const endPart = match[3] || ''

    if (isVoidElement(tagName)) {
      // If it's a void element and doesn't end with '>' or '/>', it's malformed
      if (!fullMatch.endsWith('>')) {
        throw new Error(
          `Void element <${tagName}${attributes}${endPart} must be properly closed with '>' or '/>'`
        )
      }
    }
  }

  // Check for unclosed angle brackets at the end of the document
  const lastOpenBracket = html.lastIndexOf('<')
  const lastCloseBracket = html.lastIndexOf('>')

  if (lastOpenBracket > lastCloseBracket) {
    // Extract the partial tag to include in the error message
    const partialTag = html.substring(lastOpenBracket, html.length)
    throw new Error(`Unclosed tag at end of document: ${partialTag}`)
  }
}
