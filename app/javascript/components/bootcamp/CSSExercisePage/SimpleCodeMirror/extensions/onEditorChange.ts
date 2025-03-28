import { EditorView, ViewUpdate } from '@codemirror/view'

export function onEditorChange(...cb: Array<(update: ViewUpdate) => void>) {
  return EditorView.updateListener.of((update) => {
    if (update.docChanged) {
      cb.forEach((fn) => fn(update))
    }
  })
}
