// list of elements that don't require a closing tag
export const voidElements = new Set([
  // HTML void elements
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
  // svg
  'circle',
  'ellipse',
  'line',
  'path',
  'polygon',
  'polyline',
  'rect',
  'stop',
  'use',
  'image',
])

export function isVoidElement(tagName: string): boolean {
  return voidElements.has(tagName.toLowerCase())
}
