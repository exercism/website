import { EditorView } from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'
import { syntaxTree } from '@codemirror/language'
import { FAUX_RANGE_INPUT_ID } from '.'
import { formatNumber, getSensitivity } from './utils'
import { assetUrl } from '@/utils/assets'

export function appendNumberScrubber({
  top,
  left,
  originalValue,
  unit,
  node,
  view,
}: {
  top: number
  left: number
  originalValue: number
  unit: string
  node: SyntaxNode
  view: EditorView
}) {
  const id = FAUX_RANGE_INPUT_ID
  const scrubber = document.createElement('div')
  scrubber.id = id
  Object.assign(scrubber.style, {
    position: 'absolute',
    top: `${top}px`,
    left: `${left}px`,
    transform: 'translate(-50%, -100%)',
    zIndex: '9999',
    width: '34px',
    height: '20px',
    backgroundColor: 'white',
    backgroundImage: `url(${assetUrl('icons/move.svg')})`,
    backgroundSize: 'contain',
    backgroundRepeat: 'no-repeat',
    backgroundPosition: 'center center',
    filter: 'drop-shadow(0px 0px 5px rgba(0, 120, 255, 0.5))',
    borderRadius: '5px',
    cursor: 'ew-resize',
    userSelect: 'none',
  })

  // This tooltip can be appended if we'd like to - keep this for debug purposes
  // const tooltip = createTooltip(`${originalValue}${unit}`)
  // scrubber.appendChild(tooltip)

  let isDragging = false
  let startX = 0
  let currentDelta = 0

  // we can multiply the delta with sensitivity
  // can be made kinda dynamic with getSensitivity util function
  let sensitivity = getSensitivity(originalValue)

  const onMouseMove = (e: MouseEvent) => {
    if (!isDragging) return
    currentDelta = e.clientX - startX
    scrubber.style.left = `${left + currentDelta}px`

    const deltaValue = currentDelta * sensitivity
    const newValue = formatNumber(originalValue + deltaValue)
    // tooltip.textContent = `${newValue}${unit}`

    const updatedTree = syntaxTree(view.state)
    const currentNode = updatedTree.resolve(node.from, 1)
    const currentUnitNode = currentNode.getChild('Unit')
    const to = currentUnitNode ? currentUnitNode.to : currentNode.to

    view.dispatch({
      changes: {
        from: currentNode.from,
        to,
        insert: `${newValue}${unit}`,
      },
    })
  }

  const onMouseUp = () => {
    if (!isDragging) return
    isDragging = false
    scrubber.style.left = `${left}px`

    const updatedTree = syntaxTree(view.state)
    const updatedNode = updatedTree.resolve(node.from, 1)
    const updatedUnitNode = updatedNode.getChild('Unit')
    const to = updatedUnitNode ? updatedUnitNode.from : updatedNode.to
    const updatedText = view.state.sliceDoc(updatedNode.from, to).trim()
    const parsed = parseFloat(updatedText)

    if (!isNaN(parsed)) {
      originalValue = parsed
      sensitivity = getSensitivity(originalValue)

      // tooltip.textContent = `${originalValue}${unit}`
    }

    document.removeEventListener('mousemove', onMouseMove)
    document.removeEventListener('mouseup', onMouseUp)
  }

  scrubber.addEventListener('mousedown', (e: MouseEvent) => {
    e.preventDefault()
    isDragging = true
    startX = e.clientX
    document.addEventListener('mousemove', onMouseMove)
    document.addEventListener('mouseup', onMouseUp)
  })

  document.body.appendChild(scrubber)

  // remove element if it's inactive for 3 seconds
  setTimeout(() => {
    if (document.getElementById(id) && !isDragging) {
      scrubber.remove()
    }
  }, 3000)
}
