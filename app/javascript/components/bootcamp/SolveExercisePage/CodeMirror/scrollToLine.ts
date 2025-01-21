import { EditorView } from '@codemirror/view'

export function scrollToLine(view: EditorView | null, line: number): void {
  if (!view) return
  const doc = view.state.doc
  const linePos = doc.line(line)
  const lineBlock = view.lineBlockAt(linePos.from)
  if (lineBlock) {
    const viewportHeight = view.scrollDOM.clientHeight
    const blockHeight = lineBlock.bottom - lineBlock.top

    const centeredTop = lineBlock.top - viewportHeight / 2 + blockHeight / 2

    view.scrollDOM.scrollTo({ top: centeredTop })
  }
}
