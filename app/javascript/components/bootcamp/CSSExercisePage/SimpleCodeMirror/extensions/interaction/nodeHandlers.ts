import { EditorView } from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'
import { handleNumberNode } from './handlers/handleNumberNode'
import { handleColorNode } from './handlers/handleColorNode'
import { getIsColorNode, getIsNumberNode } from './syntaxNodeChecks'

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
