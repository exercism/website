import { EditorView } from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'
import { syntaxTree } from '@codemirror/language'
import { cursorPositionHelper } from '../utils'

const FAUX_RANGE_INPUT_ID = 'faux-range'

export function handleNumberNode(node: SyntaxNode, view: EditorView) {
  const { top, left, isCursorInside } = cursorPositionHelper(view, node)
  if (!isCursorInside) {
    removeExistingScrubber()
    return
  }

  const currentTree = syntaxTree(view.state)
  const nodeAtCursor = currentTree.resolve(node.from, 1)
  const unitNode = nodeAtCursor.getChild('Unit')

  if (!unitNode) return
  const unit = view.state.sliceDoc(unitNode.from, unitNode.to)
  const numberText = view.state.sliceDoc(node.from, unitNode.from).trim()
  let originalValue = parseFloat(numberText)
  if (isNaN(originalValue)) return

  const id = FAUX_RANGE_INPUT_ID
  const existingScrubber = document.getElementById(id)
  if (existingScrubber) {
    existingScrubber.style.top = `${top}px`
    existingScrubber.style.left = `${left}px`
    return
  }

  const scrubber = document.createElement('div')
  scrubber.id = id
  Object.assign(scrubber.style, {
    position: 'absolute',
    top: `${top}px`,
    left: `${left}px`,
    transform: 'translate(-50%, -100%)',
    zIndex: '9999',
    width: '30px',
    height: '20px',
    background: 'rgba(0, 120, 255, 0.2)',
    border: '1px solid rgba(0, 120, 255, 0.5)',
    borderRadius: '3px',
    cursor: 'ew-resize',
    userSelect: 'none',
  })

  const tooltip = document.createElement('div')
  tooltip.className = 'number-tooltip'
  Object.assign(tooltip.style, {
    position: 'absolute',
    top: '-18px',
    left: '50%',
    transform: 'translateX(-50%)',
    background: 'rgba(0, 0, 0, 0.7)',
    color: 'white',
    padding: '2px 6px',
    borderRadius: '3px',
    fontSize: '11px',
    pointerEvents: 'none',
    whiteSpace: 'nowrap',
  })
  tooltip.textContent = `${originalValue}${unit}`
  scrubber.appendChild(tooltip)

  let isDragging = false
  let startX = 0
  let currentDelta = 0

  const getSensitivity = (val: number) => 1
  // Math.abs(val) >= 1 ? 1 : 0.5

  let sensitivity = getSensitivity(originalValue)

  const onMouseMove = (e: MouseEvent) => {
    if (!isDragging) return

    currentDelta = e.clientX - startX
    scrubber.style.left = `${left + currentDelta}px`

    const valueChange = currentDelta * sensitivity
    const newValue = formatNumber(originalValue + valueChange)
    tooltip.textContent = `${newValue}${unit}`

    const currentTree = syntaxTree(view.state)
    const currentNode = currentTree.resolve(node.from, 1)
    const currentUnitNode = currentNode.getChild('Unit')
    if (!currentUnitNode) return

    view.dispatch({
      changes: {
        from: currentNode.from,
        to: currentUnitNode.to,
        insert: `${newValue}${unit}`,
      },
    })
  }

  const onMouseUp = () => {
    if (!isDragging) return
    isDragging = false

    // make sure scrubber snaps back to the original position
    scrubber.style.left = `${left}px`
    scrubber.style.background = 'rgba(0, 120, 255, 0.2)'

    // update baseline val
    const updatedTree = syntaxTree(view.state)
    const updatedNode = updatedTree.resolve(node.from, 1)
    const updatedUnitNode = updatedNode.getChild('Unit')
    if (updatedUnitNode) {
      const updatedNumberText = view.state
        .sliceDoc(updatedNode.from, updatedUnitNode.from)
        .trim()
      const parsed = parseFloat(updatedNumberText)
      if (!isNaN(parsed)) {
        originalValue = parsed
        sensitivity = getSensitivity(originalValue)
        tooltip.textContent = `${originalValue}${unit}`
      }
    }

    document.removeEventListener('mousemove', onMouseMove)
    document.removeEventListener('mouseup', onMouseUp)
  }

  scrubber.addEventListener('mousedown', (e: MouseEvent) => {
    e.preventDefault()
    isDragging = true
    startX = e.clientX
    scrubber.style.background = 'rgba(0, 120, 255, 0.4)'
    document.addEventListener('mousemove', onMouseMove)
    document.addEventListener('mouseup', onMouseUp)
  })

  document.body.appendChild(scrubber)

  // remove scrubber after 3 secs of inactivity
  setTimeout(() => {
    if (document.getElementById(id) && !isDragging) {
      scrubber.remove()
    }
  }, 3000)
}

function removeExistingScrubber() {
  const scrubber = document.getElementById(FAUX_RANGE_INPUT_ID)
  if (scrubber) scrubber.remove()
}

function formatNumber(value: number): number {
  if (Math.abs(value) >= 10) return Math.round(value * 10) / 10
  if (Math.abs(value) >= 1) return Math.round(value * 100) / 100
  return Math.round(value * 1000) / 1000
}
