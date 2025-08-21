import type { StateField } from '@codemirror/state'
import type { EditorView } from 'codemirror'

export function getCodeMirrorFieldValue(
  view: EditorView | null,
  field: StateField<any>
): any {
  if (!view) return
  return view.state.field(field)
}
