import React, {
  useState,
  useEffect,
  forwardRef,
  type ForwardedRef,
  useContext,
  useMemo,
} from 'react'
import { EditorView, ViewUpdate } from '@codemirror/view'
import { EditorState, Compartment } from '@codemirror/state'
import { minimalSetup } from 'codemirror'
import { indentWithTab } from '@codemirror/commands'
import {
  keymap,
  highlightActiveLine,
  dropCursor,
  rectangularSelection,
  crosshairCursor,
  lineNumbers,
  highlightActiveLineGutter,
} from '@codemirror/view'
import {
  indentOnInput,
  bracketMatching,
  foldKeymap,
} from '@codemirror/language'
import { defaultKeymap, historyKeymap } from '@codemirror/commands'
import { searchKeymap } from '@codemirror/search'
import { lintKeymap } from '@codemirror/lint'

import useEditorStore from '../store/editorStore'

import * as Ext from './extensions'
import * as Hook from './hooks'
import { INFO_HIGHLIGHT_COLOR } from './extensions/lineHighlighter'
import { debounce } from 'lodash'
import { jikiscript } from 'codemirror-lang-jikiscript'

export const readonlyCompartment = new Compartment()

export type Handler = {
  setValue: (value: string) => void
  getValue: () => string
  focus: () => void
}

export type ViewRef = React.MutableRefObject<EditorView | null>

function onEditorChange(...cb: Array<(update: ViewUpdate) => void>) {
  return EditorView.updateListener.of((update) => {
    if (update.docChanged) {
      cb.forEach((fn) => fn(update))
    }
  })
}

function onEditorFocus(...cb: Array<(update: ViewUpdate) => void>) {
  return EditorView.updateListener.of((update) => {
    if (update.view.hasFocus) {
      cb.forEach((fn) => fn(update))
    }
  })
}

export const CodeMirror = forwardRef(function _CodeMirror(
  {
    editorDidMount,
    handleRunCode,
    style,
    setEditorLocalStorageValue,
    onEditorChangeCallback,
  }: {
    editorDidMount: (handler: Handler) => void
    handleRunCode: () => void
    style?: React.CSSProperties
    onEditorChangeCallback?: () => void
    setEditorLocalStorageValue: (value: {
      code: string
      storedAt: string
    }) => void
  },
  ref: ForwardedRef<EditorView | null>
) {
  const {
    readonly,
    defaultCode,
    setHasCodeBeenEdited,
    shouldShowInformationWidget,
    underlineRange,
    setUnderlineRange,
    setHighlightedLineColor,
    setShouldShowInformationWidget,
    highlightedLineColor,
    setHighlightedLine,
    highlightedLine,
    informationWidgetData,
    setInformationWidgetData,
  } = useEditorStore()

  const [textarea, setTextarea] = useState<HTMLDivElement | null>(null)

  const updateLocalStorageValueOnDebounce = useMemo(() => {
    return debounce(
      (value: string) =>
        setEditorLocalStorageValue({
          code: value,
          storedAt: new Date().toISOString(),
        }),
      500
    )
  }, [setEditorLocalStorageValue])

  let value = defaultCode

  const getEditorView = (): EditorView | null => {
    if (typeof ref === 'function') {
      throw new Error('Callback refs are not supported.')
    }
    if (ref === null) return null
    return ref.current
  }

  const setValue = (text: string) => {
    const editorView = getEditorView()
    if (!editorView) {
      return
    }

    const transaction = editorView.state.update({
      changes: {
        from: 0,
        to: editorView.state.doc.length,
        insert: text,
      },
    })

    editorView.dispatch(transaction)
  }

  const getValue = () => {
    const editorView = getEditorView()
    return (value = editorView?.state.doc.toString() || '')
  }

  useEffect(() => {
    if (!textarea || getEditorView()) {
      return
    }

    const view = new EditorView({
      state: EditorState.create({
        doc: value,
        extensions: [
          Ext.underlineExtension(),
          Ext.readOnlyRangeDecoration(),
          Ext.colorScheme,
          minimalSetup,
          lineNumbers(),
          highlightActiveLineGutter(),
          dropCursor(),
          EditorState.allowMultipleSelections.of(true),
          indentOnInput(),
          bracketMatching(),
          rectangularSelection(),
          crosshairCursor(),
          highlightActiveLine(),
          keymap.of([
            ...defaultKeymap,
            ...searchKeymap,
            ...historyKeymap,
            ...foldKeymap,
            ...lintKeymap,
            indentWithTab,
          ]),
          jikiscript(),
          Ext.highlightLine(highlightedLine),
          Ext.showInfoWidgetField,
          Ext.informationWidgetDataField,
          Ext.lineInformationExtension(),
          Ext.multiHighlightLine({ from: 0, to: 0 }),
          readonlyCompartment.of([EditorView.editable.of(!readonly)]),
          onEditorFocus(
            () => setShouldShowInformationWidget(false),
            () =>
              setInformationWidgetData({
                html: '',
                line: 0,
                status: 'SUCCESS',
              })
          ),
          onEditorChange(
            () => setHighlightedLine(0),
            (e) => {
              updateLocalStorageValueOnDebounce(e.state.doc.toString())
            },
            () => setHighlightedLineColor(INFO_HIGHLIGHT_COLOR),
            () => setHasCodeBeenEdited(true),
            () => setUnderlineRange(undefined),
            () => {
              const { shouldAutoRunCode } = useEditorStore.getState()
              if (shouldAutoRunCode) {
                handleRunCode()
              }
            },
            () => {
              console.log('editor change callback')
              if (onEditorChangeCallback) {
                onEditorChangeCallback()
              } else {
                console.log('no editor callback')
              }
            }
          ),
          Ext.cursorTooltip(),
          Ext.highlightedCodeBlock(),
          Ext.initReadOnlyRangesExtension(),
        ],
      }),
      parent: textarea,
    })

    if (typeof ref === 'function') {
      throw new Error('Callback refs are not supported.')
    } else if (ref) {
      ref.current = view
    }

    editorDidMount({ setValue, getValue, focus: view.focus.bind(view) })
  })

  Hook.useReadonlyCompartment(getEditorView(), readonly)

  Hook.useHighlightLine(getEditorView(), highlightedLine)
  Hook.useHighlightLineColor(getEditorView(), highlightedLineColor)
  Hook.useUnderlineRange(getEditorView(), underlineRange)
  // Hook.useReadonlyRanges(getEditorView(), readonlyRanges);

  useEffect(() => {
    const editorView = getEditorView()
    if (!editorView || shouldShowInformationWidget === undefined) return
    editorView.dispatch({
      effects: Ext.showInfoWidgetEffect.of(shouldShowInformationWidget),
    })
  }, [shouldShowInformationWidget])

  useEffect(() => {
    const editorView = getEditorView()
    if (!editorView || informationWidgetData === undefined) return

    editorView.dispatch({
      effects: Ext.informationWidgetDataEffect.of(informationWidgetData),
    })
  }, [informationWidgetData?.html, informationWidgetData?.line])

  return (
    <div className="editor-wrapper" style={style}>
      <div data-cy="codemirror-editor" className="editor" ref={setTextarea} />
    </div>
  )
})
