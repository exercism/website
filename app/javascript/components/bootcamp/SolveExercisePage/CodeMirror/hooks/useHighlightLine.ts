import { useEffect } from 'react'
import { changeLineEffect } from '../extensions/lineHighlighter'
import type { EditorView } from 'codemirror'

export function useHighlightLine(
  editorView: EditorView | null,
  highlightedLine: number
) {
  useEffect(() => {
    if (!editorView) {
      return
    }

    // dispatch a transaction which syncs cm's inner state with React's state
    if (highlightedLine !== undefined) {
      editorView.dispatch({
        effects: changeLineEffect.of(highlightedLine),
      })
    }
  }, [highlightedLine])
}
