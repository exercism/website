import { StateEffect } from '@codemirror/state'
import type { EditorView } from 'codemirror'

// This can be added to any extension that needs to be cleaned up. e.g. underlineRange, highlightLine, etc
export const cleanUpEditorEffect = StateEffect.define<void>()

/**
 * Cleans up the editor by removing all decorations and marks.
 */
export function cleanUpEditor(view: EditorView | null) {
  if (!view) return
  view.dispatch({
    effects: cleanUpEditorEffect.of(),
  })
}
