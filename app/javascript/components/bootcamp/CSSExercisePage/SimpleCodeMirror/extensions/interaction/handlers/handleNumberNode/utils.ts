import { EditorView } from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'
import { syntaxTree } from '@codemirror/language'
import { FAUX_RANGE_INPUT_ID } from '.'

// === Scrubber utils ===

export function getSensitivity(value: number): number {
  // we can add multiple rules like this and chain them
  // return Math.abs(value) >= 10 ? 1: 0.5
  return 1
}

export function extractNumberAndUnit(view: EditorView, node: SyntaxNode) {
  const currentTree = syntaxTree(view.state)
  const nodeAtCursor = currentTree.resolve(node.from, 1)
  const unitNode = nodeAtCursor.getChild('Unit')

  let numberText = ''
  let unit = ''

  if (unitNode) {
    unit = view.state.sliceDoc(unitNode.from, unitNode.to)
    numberText = view.state.sliceDoc(node.from, unitNode.from).trim()
  } else {
    numberText = view.state.sliceDoc(node.from, node.to).trim()
  }

  return { numberText, unit }
}

// we might just want to round the numbers
export function formatNumber(value: number): number {
  if (Math.abs(value) >= 10) return Math.round(value * 10) / 10
  if (Math.abs(value) >= 1) return Math.round(value * 100) / 100
  return Math.round(value * 1000) / 1000
}

export function removeExistingScrubber() {
  const existing = document.getElementById(FAUX_RANGE_INPUT_ID)
  if (existing) existing.remove()
}
