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
  error: StaticError
  setUnderlineRange: (range: { from: number; to: number }) => void
  setHighlightedLine: (line: number) => void
  setHighlightedLineColor: (color: string) => void
  setInformationWidgetData: (data: InformationWidgetData) => void
  setShouldShowInformationWidget: (shouldShow: boolean) => void
  editorView: EditorView | null
  context?: string
}) {
  if (!error.location) {
    console.error('Error location is missing')
    return
  }
  setUnderlineRange({
    from: Math.max(0, error.location.absolute.begin - 1),
    to: Math.max(0, error.location.absolute.end - 1),
  })

  scrollToLine(editorView, error.location.line)
  setHighlightedLine(error.location.line)
  setHighlightedLineColor(ERROR_HIGHLIGHT_COLOR)
  setInformationWidgetData({
    html: describeError(error, context),
    line: error.location.line,
    status: 'ERROR',
  })
  setShouldShowInformationWidget(true)
}

export function showJSError({
  setUnderlineRange,
  setHighlightedLine,
  setHighlightedLineColor,
  setInformationWidgetData,
  setShouldShowInformationWidget,
  error,
  editorView,
  context,
}: {
  error: {
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

  const colNumberAbsolutePosition =
    editorView.state.doc.line(error.lineNumber).from + error.colNumber

  scrollToLine(editorView, error.lineNumber)
  // TODO add an extension that highlights tokens at location
  setUnderlineRange({
    from: colNumberAbsolutePosition - 1,
    to: colNumberAbsolutePosition,
  })
  setHighlightedLine(error.lineNumber)
  setHighlightedLineColor(ERROR_HIGHLIGHT_COLOR)
  setInformationWidgetData({
    html: describeError({
      // TODO adjust types
      // @ts-ignore
      type: error.type,
      message: error.message,
    }),
    line: error.lineNumber,
    status: 'ERROR',
  })
  setShouldShowInformationWidget(true)
}
