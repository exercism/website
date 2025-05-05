import { EditorView } from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'
import {
  appendColorInput,
  cursorPositionHelper,
  formatColorInputDefaultValue,
  hex2rgb,
} from '../../utils'
import { getIsHexNode, getIsRgbNode } from '../../nodeHandlers'
import { syntaxTree } from '@codemirror/language'

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

      const colorNode = findColorNodeUp(updatedNode)

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

function findColorNodeUp(node: SyntaxNode): SyntaxNode | null {
  let current: SyntaxNode | null = node
  while (current) {
    if (isColorSyntaxNode(current)) return current
    current = current.parent
  }
  return null
}

function isColorSyntaxNode(node: SyntaxNode): boolean {
  return (
    node.name === 'CallExpression' ||
    node.name === 'Color' ||
    node.name === 'ColorLiteral'
  )
}
