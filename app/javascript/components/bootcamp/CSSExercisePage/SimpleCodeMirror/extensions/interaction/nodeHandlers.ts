import { EditorView } from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'
import { handleNumberNode } from './handlers/handleNumberNode'
import { handleColorNode } from './handlers/handleColorNode'

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

export function handleNode(node: SyntaxNode, view: EditorView) {
  if (getIsColorNode(view, node)) {
    requestAnimationFrame(() => handleColorNode(node, view))
  } else if (getIsNumberNode(node)) {
    requestAnimationFrame(() => handleNumberNode(node, view))
  }
}

// Helpers
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
