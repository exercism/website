import { EditorView } from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'

export function getIsColorNode(view: EditorView, node: SyntaxNode) {
  return getIsHexNode(node) || getIsRgbNode(view, node)
}

export function getIsRgbNode(view: EditorView, node: SyntaxNode) {
  const nodeContent = view.state.sliceDoc(node.from, node.to)
  return node.type.name === 'CallExpression' && nodeContent.startsWith('rgb')
}

export function getIsHexNode(node: SyntaxNode) {
  return node.type.name === 'ColorLiteral'
}

export function getIsNumberNode(node: SyntaxNode) {
  return node.type.name === 'NumberLiteral'
}
