import { EditorView } from '@codemirror/view'
import { foldedRanges, foldState } from '@codemirror/language'

export function getFoldedRanges(view: EditorView | null) {
  if (!view) return
  const state = view.state
  const foldRanges = view.state.field(foldState)
  if (!foldRanges) {
    return
  }

  const results: { from: number; to: number }[] = []
  foldRanges.between(0, state.doc.length, (from, to) => {
    const startLine = state.doc.lineAt(from).number
    const endLine = state.doc.lineAt(to).number
    results.push({ from: startLine, to: endLine })
  })

  return results
}
