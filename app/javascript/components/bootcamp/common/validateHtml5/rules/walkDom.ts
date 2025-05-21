// rules/walkDom.ts
import { isVoidElement } from '../voidElements'

export function walkDom(document): {
  success: boolean
  message?: string
} {
  const stack: string[] = []

  function walk(node: any): boolean {
    if (node.nodeName === '#text' || node.nodeName === '#comment') return true

    const tagName = node.tagName

    if (tagName && !isVoidElement(tagName)) {
      stack.push(tagName)
    }

    if (node.childNodes) {
      for (const child of node.childNodes) {
        if (!walk(child)) return false
      }
    }

    if (tagName && !isVoidElement(tagName)) {
      const expected = stack.pop()
      if (expected !== tagName) {
        return false
      }
    }

    return true
  }

  const success = walk(document)
  if (!success) {
    return {
      success: false,
      message: 'Mismatched tag structure in DOM traversal',
    }
  }

  if (stack.length > 0) {
    return {
      success: false,
      message: `Unclosed tag(s): ${stack.join(', ')}`,
    }
  }

  return { success: true }
}
