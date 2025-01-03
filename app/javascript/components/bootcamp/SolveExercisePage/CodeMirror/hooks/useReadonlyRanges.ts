import { useEffect } from 'react'
import type { EditorView } from 'codemirror'
import { updateReadOnlyRangesEffect } from '../extensions/read-only-ranges/readOnlyRanges'

export function useReadonlyRanges(
  editorView: EditorView | null,
  readonlyRanges: Array<{ from: number; to: number }>
) {
  useEffect(() => {
    if (!editorView) {
      return
    }

    editorView.dispatch({
      effects: updateReadOnlyRangesEffect.of(readonlyRanges),
    })
  }, [readonlyRanges])
}
