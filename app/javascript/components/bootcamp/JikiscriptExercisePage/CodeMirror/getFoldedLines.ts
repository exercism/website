import { EditorView } from '@codemirror/view'
import { foldState } from '@codemirror/language'

export function getFoldedLines(view: EditorView | null): number[] {
  if (!view) return []
  const state = view.state
  const foldRanges = view.state.field(foldState)
  if (!foldRanges) {
    return []
  }

  const results: number[] = []
  foldRanges.between(0, state.doc.length, (from, to) => {
    const startLine = state.doc.lineAt(from).number
    const endLine = state.doc.lineAt(to).number
    // Add all numbers from endLine to startLine to the results array
    for (let i = startLine; i <= endLine; i++) {
      results.push(i)
    }
  })

  return results
}
