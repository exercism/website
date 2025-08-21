import { EditorView } from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'

export function cursorPositionHelper(view: EditorView, node: SyntaxNode) {
  const cursorPos = view.state.selection.main.head
  const coords = view.coordsAtPos(cursorPos)
  const isCursorInside = node.from <= cursorPos && cursorPos <= node.to
  return {
    isCursorInside,
    top: coords?.top || 0,
    left: coords?.left || 0,
  }
}

export function findNodeAtCursor(
  node: SyntaxNode,
  cursorPos: number,
  cb: (node: SyntaxNode) => boolean
): boolean {
  const cursor = node.cursor()
  do {
    const current = cursor.node
    if (current.from <= cursorPos && cursorPos <= current.to) {
      if (cb(current)) return true
    }
  } while (cursor.next())
  return false
}

export function hex2rgb(hex: string): [number, number, number] {
  const v = parseInt(hex.substring(1), 16)
  return [(v >> 16) & 255, (v >> 8) & 255, v & 255]
}

export function rgb2hex(r: number, g: number, b: number): string {
  return `#${r.toString(16)}${g.toString(16)}${b.toString(16)}`
}
