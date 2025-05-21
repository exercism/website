// list of elements that don't require a closing tag
export const voidElements = new Set([
  'area',
  'base',
  'br',
  'col',
  'embed',
  'hr',
  'img',
  'input',
  'link',
  'meta',
  'source',
  'track',
  'wbr',
])

export function isVoidElement(tagName: string): boolean {
  return voidElements.has(tagName.toLowerCase())
}
