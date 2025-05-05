import { EditorView } from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'
import { handleNumberNode } from './handlers/handleNumberNode'
import { handleColorNode } from './handlers/handleColorNode'

export function handleNode(node: SyntaxNode, view: EditorView) {
  if (getIsColorNode(view, node)) {
    handleColorNode(node, view)
    return true
  } else if (getIsNumberNode(node)) {
    handleNumberNode(node, view)
    return true
  }
  return false
}

function getIsColorNode(view: EditorView, node: SyntaxNode) {
  return getIsHexNode(node) || getIsRgbNode(view, node)
}

export function getIsRgbNode(view: EditorView, node: SyntaxNode) {
  const nodeContent = view.state.sliceDoc(node.from, node.to)
  return node.type.name === 'CallExpression' && nodeContent.startsWith('rgb')
}

export function getIsHexNode(node: SyntaxNode) {
  return node.type.name === 'ColorLiteral'
}

function getIsNumberNode(node: SyntaxNode) {
  return node.type.name === 'NumberLiteral'
}

export function traverseTree(node: SyntaxNode, cb: (node: SyntaxNode) => void) {
  const cursor = node.cursor()
  do {
    cb(cursor.node)
  } while (cursor.next())
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
