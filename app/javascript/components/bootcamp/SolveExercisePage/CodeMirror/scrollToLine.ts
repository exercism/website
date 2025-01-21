import { EditorView } from '@codemirror/view'

export function scrollToLine(view: EditorView | null, line: number): void {
  if (!view) return
  const doc = view.state.doc
  const linePos = doc.line(line)
  if (linePos) {
    view.dispatch({
      effects: EditorView.scrollIntoView(linePos.from, { y: 'center' }),
    })
  }
}
