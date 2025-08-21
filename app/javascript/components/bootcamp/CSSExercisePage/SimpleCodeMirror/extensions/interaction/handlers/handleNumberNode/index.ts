import { EditorView } from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'
import { cursorPositionHelper } from '../../utils'
import { appendNumberScrubber } from './appendNumberScrubber'
import { removeExistingScrubber, extractNumberAndUnit } from './utils'

export const FAUX_RANGE_INPUT_ID = 'faux-range'

export function handleNumberNode(node: SyntaxNode, view: EditorView) {
  const { top, left, isCursorInside } = cursorPositionHelper(view, node)
  if (!isCursorInside) {
    removeExistingScrubber()
    return
  }

  const { numberText, unit } = extractNumberAndUnit(view, node)
  let originalValue = parseFloat(numberText)
  if (isNaN(originalValue)) return

  const existing = document.getElementById(FAUX_RANGE_INPUT_ID)
  if (existing) {
    existing.style.top = `${top}px`
    existing.style.left = `${left}px`
    return
  }

  appendNumberScrubber({
    top,
    left,
    originalValue,
    unit,
    node,
    view,
  })
}
