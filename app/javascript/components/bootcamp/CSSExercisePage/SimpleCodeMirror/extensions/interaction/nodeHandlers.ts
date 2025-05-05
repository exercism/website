import { EditorView } from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'
import { handleNumberNode } from './handlers/handleNumberNode'
import { handleColorNode } from './handlers/handleColorNode'
import { cursorPositionHelper } from './utils'

const COLOR_INPUT_ID = 'editor-color-input'
const FAUX_RANGE_INPUT_ID = 'faux-range'

export function removeInputElements() {
  const colorInput = document.getElementById(COLOR_INPUT_ID)
  const fauxRange = document.getElementById(FAUX_RANGE_INPUT_ID)

  if (colorInput && document.activeElement !== colorInput) {
    colorInput.remove()
  }
  if (fauxRange) {
    fauxRange.remove()
  }
}

// TODO: activate this once colournode handler is fine
// remove requestAnimFrame - it's been moved a level up
// export function handleNode(node: SyntaxNode, view: EditorView): boolean {
//   const { isCursorInside } = cursorPositionHelper(view, node)

//   if (!isCursorInside) return false

//   if (getIsColorNode(view, node)) {
//     requestAnimationFrame(() => handleColorNode(node, view))
//     return true
//   } else if (getIsNumberNode(node)) {
//     requestAnimationFrame(() => handleNumberNode(node, view))
//     return true
//   }

//   return false
// }
export function handleNode(node: SyntaxNode, view: EditorView) {
  if (getIsNumberNode(node)) {
    handleNumberNode(node, view)
    return true
  }
  return false
}

function getIsColorNode(view: EditorView, node: SyntaxNode) {
  return getIsHexNode(node) || getIsRgbNode(view, node)
}

function getIsRgbNode(view: EditorView, node: SyntaxNode) {
  const nodeContent = view.state.sliceDoc(node.from, node.to)
  return node.type.name === 'CallExpression' && nodeContent.startsWith('rgb')
}

function getIsHexNode(node: SyntaxNode) {
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
