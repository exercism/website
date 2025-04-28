import type { StaticError } from '@/interpreter/error'
import { describeError } from '../CodeMirror/extensions/end-line-information/describeError'
import { type InformationWidgetData } from '../CodeMirror/extensions/end-line-information/line-information'
import { ERROR_HIGHLIGHT_COLOR } from '../CodeMirror/extensions/lineHighlighter'
import { scrollToLine } from '../CodeMirror/scrollToLine'
import { EditorView } from '@codemirror/view'

// TODO: maybe move this into exercise store
export function showError({
  setUnderlineRange,
  setHighlightedLine,
  setHighlightedLineColor,
  setInformationWidgetData,
  setShouldShowInformationWidget,
  error,
  editorView,
  context,
}: {
  error:
    | StaticError
    | {
        type: string
        message: string
        lineNumber: number
        colNumber: number
      }
  setUnderlineRange: (range: { from: number; to: number }) => void
  setHighlightedLine: (line: number) => void
  setHighlightedLineColor: (color: string) => void
  setInformationWidgetData: (data: InformationWidgetData) => void
  setShouldShowInformationWidget: (shouldShow: boolean) => void
  editorView: EditorView | null
  context?: string
}) {
  if (!editorView) return

  let from = 0
  let to = 0
  let line = 1
  let html = ''
  const status = 'ERROR' as const

  // If 'location' exists in error, it means it's a Jikiscript error,
  // and we can make it behave as it used to.
  if ('location' in error) {
    if (!error.location) {
      console.error('Error location is missing')
      return
    }

    from = Math.max(0, error.location.absolute.begin - 1)
    to = Math.max(0, error.location.absolute.end - 1)
    line = error.location.line
    html = describeError(error, 'jikiscript', context)
  } else {
    // Codemirror requires a 1-based line number, while Js's error output generates a 0-based line number
    const lineNumber = error.lineNumber + 1
    // Otherwise it's a JS error, and typeof `error` is not StaticError
    // on this error we - for example - don't have `location`.
    const pos = editorView.state.doc.line(lineNumber).from + error.colNumber
    from = pos - 1
    to = pos
    line = lineNumber
    html = describeError(
      {
        // @ts-expect-error - partial StaticError-like structure
        // TODO: adjust types in describeError
        type: error.type,
        message: error.message,
      },
      'javascript'
    )
  }

  scrollToLine(editorView, line)
  setUnderlineRange({ from, to })
  setHighlightedLine(line)
  setHighlightedLineColor(ERROR_HIGHLIGHT_COLOR)
  setInformationWidgetData({ html, line, status })
  setShouldShowInformationWidget(true)
}
