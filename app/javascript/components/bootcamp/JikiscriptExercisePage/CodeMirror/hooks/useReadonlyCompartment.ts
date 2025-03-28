import { EditorView } from '@codemirror/view'
import { useEffect } from 'react'
import { type ViewRef, readonlyCompartment } from '../CodeMirror'

export function useReadonlyCompartment(
  editorView: EditorView | null,
  readonly: boolean
) {
  useEffect(() => {
    if (!editorView) {
      return
    }

    editorView.dispatch({
      effects: readonlyCompartment.reconfigure([
        EditorView.editable.of(!readonly),
      ]),
    })
  }, [readonly])
}
