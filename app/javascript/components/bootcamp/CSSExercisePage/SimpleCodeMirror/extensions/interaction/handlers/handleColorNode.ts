import { EditorView } from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'
import { appendColorInput, cursorPositionHelper, hex2rgb } from '../utils'

export function handleColorNode(node: SyntaxNode, view: EditorView) {
  const { top, left, isCursorInside } = cursorPositionHelper(view, node)
  if (!isCursorInside) return

  const nodeContent = view.state.sliceDoc(node.from, node.to)
  appendColorInput({
    top,
    left,
    defaultValue: nodeContent,
    onChange: (color: string) => {
      const [r, g, b] = hex2rgb(color)
      const callNode = node.getChild('CallExpression') ?? node
      const argList = node.getChild('ArgList')
      if (!argList) return

      view.dispatch({
        changes: {
          from: callNode.from,
          to: callNode.to,
          insert: `rgb(${r}, ${g}, ${b})`,
        },
      })
    },
  })
}
