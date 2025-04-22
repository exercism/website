import type { StaticError } from '@/interpreter/error'
import { describeError } from '../CodeMirror/extensions/end-line-information/describeError'
import {
  informationWidgetDataEffect,
  showInfoWidgetEffect,
  type InformationWidgetData,
} from '../CodeMirror/extensions/end-line-information/line-information'
import {
  changeColorEffect,
  changeLineEffect,
  ERROR_HIGHLIGHT_COLOR,
} from '../CodeMirror/extensions/lineHighlighter'
import { scrollToLine } from '../CodeMirror/scrollToLine'
import { EditorView } from '@codemirror/view'
import { addUnderlineEffect } from '../CodeMirror/extensions/underlineRange'

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
  editorView: EditorView | null
  context?: string
}) {
  if (!editorView) return

  const colNumberAbsolutePosition = editorView.state.doc.lineAt(
    error.colNumber
  ).number

  const colNumberPosAt = editorView.state.doc.lineAt(error.colNumber)
  console.log(
    'colNumberAbsolutePosition',
    colNumberAbsolutePosition,
    colNumberPosAt
  )

  editorView.dispatch({
    effects: [
      informationWidgetDataEffect.of({
        html: describeError({
          // TODO adjust types
          // @ts-ignore
          type: error.type,
          message: error.message,
        }),
        line: error.lineNumber,
        status: 'ERROR',
      }),
      showInfoWidgetEffect.of(true),
      addUnderlineEffect.of({
        from: error.colNumber,
        to: error.colNumber,
      }),
      changeColorEffect.of(ERROR_HIGHLIGHT_COLOR),
      changeLineEffect.of(error.lineNumber),
    ],
  })

  console.log('colNumber', error.colNumber)

  scrollToLine(editorView, error.lineNumber)
  // setUnderlineRange({
  //   from: Math.max(0, error.location.absolute.begin - 1),
  //   to: Math.max(0, error.location.absolute.end - 1),
  // })
  // setHighlightedLine(error.location.line)
  // setHighlightedLineColor(ERROR_HIGHLIGHT_COLOR)
  // setInformationWidgetData({
  //   html: describeError(error, context),
  //   line: error.location.line,
  //   status: 'ERROR',
  // })
  // setShouldShowInformationWidget(true)
}
