export function numTagsUsed(html: string, maxAllowedTags: number): boolean {
  const parser = new DOMParser()
  const doc = parser.parseFromString(html, 'text/html')

  const allElements = doc.body.getElementsByTagName('*')
  return allElements.length <= maxAllowedTags
}
