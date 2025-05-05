import { EditorView } from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'
import { syntaxTree } from '@codemirror/language'
import { cursorPositionHelper } from '../utils'

const FAUX_RANGE_INPUT_ID = 'faux-range'

export function handleNumberNode(node: SyntaxNode, view: EditorView) {
  const { top, left, isCursorInside } = cursorPositionHelper(view, node)
  if (!isCursorInside) return

  const currentTree = syntaxTree(view.state)
  const nodeAtCursor = currentTree.resolve(node.from, 1)
  const unitNode = nodeAtCursor.getChild('Unit')

  if (unitNode) {
    const unit = view.state.sliceDoc(unitNode.from, unitNode.to)
    const numberText = view.state.sliceDoc(node.from, unitNode.from).trim()
    let currentNumber = parseFloat(numberText)
    const id = FAUX_RANGE_INPUT_ID

    if (document.getElementById(id)) return

    const fauxRange = document.createElement('div')
    fauxRange.id = id
    Object.assign(fauxRange.style, {
      position: 'absolute',
      top: `${top}px`,
      left: `${left}px`,
      transform: 'translate(-50%, -100%)',
      zIndex: '9999',
      width: '30px',
      height: '30px',
      background: 'red',
      cursor: 'ew-resize',
    })

    let isDragging = false
    let startX = 0
    let currentDelta = 0

    const onMouseMove = (e: MouseEvent) => {
      if (!isDragging) return
      currentDelta = e.clientX - startX
      fauxRange.style.left = `${left + currentDelta}px`

      const currentTree = syntaxTree(view.state)
      const nodeAtCursor = currentTree.resolve(node.from, 1)

      view.dispatch({
        changes: {
          from: nodeAtCursor.from,
          to: nodeAtCursor.to,
          insert: `${currentNumber + currentDelta}${unit}`,
        },
      })
    }

    const onMouseUp = () => {
      isDragging = false

      fauxRange.style.left = `${left}px`

      currentNumber = parseFloat(numberText) + currentDelta

      document.removeEventListener('mousemove', onMouseMove)
      document.removeEventListener('mouseup', onMouseUp)
    }

    fauxRange.addEventListener('mousedown', (e: MouseEvent) => {
      isDragging = true
      startX = e.clientX
      // currentDelta = 0
      document.addEventListener('mousemove', onMouseMove)
      document.addEventListener('mouseup', onMouseUp)
    })

    document.body.appendChild(fauxRange)
  }
}
