import { EditorView } from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'
import { syntaxTree } from '@codemirror/language'
import { cursorPositionHelper, hex2rgb } from '../../utils'
import { getIsHexNode, getIsRgbNode } from '../../syntaxNodeChecks'
import { appendColorInput } from './appendColorInput'
import { formatColorInputDefaultValue } from './formatColorInputDefaultValue'
import { findColorNodeAbove } from './findColorNodeAbove'

export function handleColorNode(node: SyntaxNode, view: EditorView) {
  const { top, left, isCursorInside } = cursorPositionHelper(view, node)
  if (!isCursorInside) return

  const nodeContent = view.state.sliceDoc(node.from, node.to)
  const isHex = getIsHexNode(node)
  const isRgb = getIsRgbNode(view, node)

  if (!isHex && !isRgb) return

  appendColorInput({
    top,
    left,
    defaultValue: formatColorInputDefaultValue(nodeContent),
    onChange: (color: string) => {
      let newColor = color

      if (isRgb) {
        const [r, g, b] = hex2rgb(color)
        newColor = `rgb(${r}, ${g}, ${b})`
      }
      const cursorPos = view.state.selection.main.head
      const updatedTree = syntaxTree(view.state)
      const updatedNode = updatedTree.resolve(cursorPos, 1)
      const colorNode = findColorNodeAbove(view, updatedNode)
      if (!colorNode) return

      view.dispatch({
        changes: {
          from: colorNode.from,
          to: colorNode.to,
          insert: newColor,
        },
      })
    },
  })
}
