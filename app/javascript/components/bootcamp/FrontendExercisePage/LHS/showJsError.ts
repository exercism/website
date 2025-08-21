import { EditorView } from 'codemirror'
import {
  showInfoWidgetEffect,
  informationWidgetDataEffect,
} from '../../JikiscriptExercisePage/CodeMirror/extensions'
import {
  changeColorEffect,
  ERROR_HIGHLIGHT_COLOR,
  changeLineEffect,
} from '../../JikiscriptExercisePage/CodeMirror/extensions/lineHighlighter'
import { addUnderlineEffect } from '../../JikiscriptExercisePage/CodeMirror/extensions/underlineRange'
import { scrollToLine } from '../../JikiscriptExercisePage/CodeMirror/scrollToLine'

export function showJsError(
  view: EditorView | null,
  error: { message: string; lineNumber: number; colNumber: number }
) {
  if (!view) return

  setTimeout(() => scrollToLine(view, error.lineNumber), 50)

  const editorLength = view.state.doc.length
  const errorLine = view.state.doc.line(error.lineNumber)
  const basePos = errorLine.from + error.colNumber - 1

  // range rules to avoid breaking:
  // from < to
  // from > 0
  // to <= editorLength
  const from = Math.max(0, Math.min(basePos, editorLength - 1))
  const to = Math.min(editorLength, from + 1)

  view.dispatch({
    effects: [
      showInfoWidgetEffect.of(true),
      informationWidgetDataEffect.of({
        html: describeJSError({ message: error.message }),
        line: error.lineNumber,
        status: 'ERROR',
      }),

      changeColorEffect.of(ERROR_HIGHLIGHT_COLOR),
      addUnderlineEffect.of({
        from,
        to,
      }),
      changeLineEffect.of(error.lineNumber),
    ],
  })
}

export function describeJSError(error: { message: string }) {
  let errorHeading = "Something didn't go as expected!"

  let output = `<h2>${errorHeading}</h2>`
  output += `<div class="content">${
    error.message ?? 'Oops! Unknown error. Please, contact us about it.'
  }`
  output += `</div>`
  return output
}

export function cleanUpEditorErrorState(view: EditorView | null) {
  if (!view) return

  view.dispatch({
    effects: [
      showInfoWidgetEffect.of(false),
      informationWidgetDataEffect.of({ html: '', line: 0, status: 'ERROR' }),
      changeColorEffect.of(''),
      changeLineEffect.of(0),
      // from:0, to:0 ==> remove underline
      addUnderlineEffect.of({ from: 0, to: 0 }),
    ],
  })
}
