import { EditorView } from 'codemirror'
import { getIsColorNode } from '../../syntaxNodeChecks'
import { SyntaxNode } from '@lezer/common'

export function findColorNodeAbove(
  view: EditorView,
  node: SyntaxNode
): SyntaxNode | null {
  let current: SyntaxNode | null = node
  while (current) {
    if (getIsColorNode(view, current)) return current
    current = current.parent
  }
  return null
}
