// tagLimits is {div: 2}, etc
export function tagOccursNoMoreThan(
  html: string,
  tagLimits: Record<string, number>
): boolean {
  const parser = new DOMParser()
  const doc = parser.parseFromString(html, 'text/html')
  const tagCounts: Record<string, number> = {}

  for (const tag in tagLimits) {
    const elements = doc.getElementsByTagName(tag)
    tagCounts[tag] = elements.length
    if (tagCounts[tag] > tagLimits[tag]) {
      return false
    }
  }

  return true
}
