import type { InformationWidgetData } from '../CodeMirror/extensions/end-line-information/line-information'
import { INFO_HIGHLIGHT_COLOR } from '../CodeMirror/extensions/lineHighlighter'
import { createStoreWithMiddlewares } from './utils'

type UnderlineRange = { from: number; to: number } | undefined

type EditorStore = {
  defaultCode: string
  setDefaultCode: (defaultCode: string) => void
  shouldAutoRunCode: boolean
  setShouldAutoRunCode: (shouldAutoRunCode: boolean) => void
  toggleShouldAutoRunCode: () => void
  readonly: boolean
  setReadonly: (readonly: boolean) => void
  hasCodeBeenEdited: boolean
  setHasCodeBeenEdited: (hasBeenEdited: boolean) => void
  shouldShowInformationWidget: boolean
  setShouldShowInformationWidget: (s: boolean) => void
  toggleShouldShowInformationWidget: () => void
  informationWidgetData: InformationWidgetData
  setInformationWidgetData: (s: InformationWidgetData) => void
  codeExecutionLevel: 'visual' | 'full'
  setCodeExecutionLevel: (level: 'visual' | 'full') => void
  toggleInformationWidget: () => void
  underlineRange: UnderlineRange
  setUnderlineRange: (range: UnderlineRange) => void
  highlightedLine: number
  setHighlightedLine: (highlightedLine: number) => void
  highlightedLineColor: string
  setHighlightedLineColor: (highlightedLine: string) => void
  readonlyRanges: Array<{ from: number; to: number }>
  setReadonlyRanges: (ranges: Array<{ from: number; to: number }>) => void
}

const useEditorStore = createStoreWithMiddlewares<EditorStore>(
  (set) => ({
    defaultCode: '',
    setDefaultCode: (defaultCode: string) => {
      set({ defaultCode }, false, 'editor/setDefaultCode')
    },
    shouldAutoRunCode: false,
    setShouldAutoRunCode: (shouldAutoRunCode) =>
      set({ shouldAutoRunCode }, false, 'editor/setShouldAutoRunCode'),
    toggleShouldAutoRunCode: () => {
      set(
        (state) => ({ shouldAutoRunCode: !state.shouldAutoRunCode }),
        false,
        'editor/toggleShouldAutoRunCode'
      )
    },
    readonly: false,
    setReadonly: (readonly) =>
      set({ readonly }, false, 'editor/setHasReadonly'),
    hasCodeBeenEdited: false,
    setHasCodeBeenEdited: (hasCodeBeenEdited) =>
      set({ hasCodeBeenEdited }, false, 'editor/setHasCodeBeenEdited'),
    shouldShowInformationWidget: false,
    setShouldShowInformationWidget: (shouldShowInformationWidget: boolean) => {
      set(
        { shouldShowInformationWidget },
        false,
        'editor/setShouldShowInformationWidget'
      )
    },
    toggleShouldShowInformationWidget: () => {
      set(
        (state) => ({
          shouldShowInformationWidget: !state.shouldShowInformationWidget,
        }),
        false,
        'editor/toggleShouldShowInformationWidget'
      )
    },
    informationWidgetData: { html: '', line: 0, status: 'SUCCESS' },
    setInformationWidgetData: (
      informationWidgetData: InformationWidgetData
    ) => {
      set(
        { informationWidgetData },
        false,
        'editor/setShouldShowInformationWidget'
      )
    },
    codeExecutionLevel: 'full',
    setCodeExecutionLevel: (level: 'visual' | 'full') => {
      set({ codeExecutionLevel: level }, false, 'editor/setCodeExecutionLevel')
    },
    underlineRange: { from: 0, to: 0 },
    setUnderlineRange: (range) => {
      set({ underlineRange: range }, false, 'editor/setUnderlineRange')
    },
    toggleInformationWidget: () => {
      set(
        (state) => ({
          shouldShowInformationWidget: !state.shouldShowInformationWidget,
        }),
        false,
        'editor/toggleInformationWidget'
      )
    },

    highlightedLine: 0,
    setHighlightedLine: (highlightedLine) => {
      set({ highlightedLine }, false, 'exercise/setHighlightedLine')
    },
    highlightedLineColor: INFO_HIGHLIGHT_COLOR,
    setHighlightedLineColor: (highlightedLineColor) => {
      set({ highlightedLineColor }, false, 'exercise/setHighlightedLineColor')
    },
    readonlyRanges: [],
    setReadonlyRanges: (readonlyRanges) => {
      set({ readonlyRanges }, false, 'exercise/setReadonlyRanges')
    },
  }),
  'EditorStore'
)

export default useEditorStore
