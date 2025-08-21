import { EditorView } from 'codemirror'

export function getEditorValue(view: EditorView) {
  return view.state.doc.toString()
}
