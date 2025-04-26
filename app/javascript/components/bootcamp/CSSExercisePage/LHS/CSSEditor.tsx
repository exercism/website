import React, { useContext, useMemo } from 'react'
import { css } from '@codemirror/lang-css'
import { cssLinter } from '../SimpleCodeMirror/extensions/cssLinter'
import { CSSExercisePageContext } from '../CSSExercisePageContext'
import { SimpleCodeMirror } from '../SimpleCodeMirror/SimpleCodeMirror'
import { useCSSExercisePageStore } from '../store/cssExercisePageStore'
import { debounce } from 'lodash'
import {
  initReadOnlyRangesExtension,
  readOnlyRangesStateField,
} from '../../JikiscriptExercisePage/CodeMirror/extensions/read-only-ranges/readOnlyRanges'
import { getCodeMirrorFieldValue } from '../../JikiscriptExercisePage/CodeMirror/getCodeMirrorFieldValue'
import { EditorView } from 'codemirror'
import { readOnlyRangeDecoration } from '../../JikiscriptExercisePage/CodeMirror/extensions/read-only-ranges/readOnlyLineDeco'
import { updateIFrame } from '../utils/updateIFrame'
import { cssTheme } from './cssTheme'

export function CSSEditor() {
  const {
    cssEditorRef,
    htmlEditorRef,
    handleCssEditorDidMount,
    setEditorCodeLocalStorage,
    actualIFrameRef,
    code,
  } = useContext(CSSExercisePageContext)
  const {
    panelSizes: { LHSWidth },
  } = useCSSExercisePageStore()

  const updateLocalStorageValueOnDebounce = useMemo(() => {
    return debounce((view: EditorView) => {
      if (!setEditorCodeLocalStorage) {
        return
      }

      const htmlReadonlyRanges = getCodeMirrorFieldValue(
        htmlEditorRef.current,
        readOnlyRangesStateField
      )

      const cssReadonlyRanges = getCodeMirrorFieldValue(
        view,
        readOnlyRangesStateField
      )

      setEditorCodeLocalStorage({
        cssEditorContent: view.state.doc.toString(),
        htmlEditorContent: htmlEditorRef.current?.state.doc.toString() || '',
        storedAt: new Date().toISOString(),
        readonlyRanges: {
          css: cssReadonlyRanges,
          html: htmlReadonlyRanges,
        },
      })
    }, 500)
  }, [setEditorCodeLocalStorage, readOnlyRangesStateField])

  return (
    <SimpleCodeMirror
      defaultCode=""
      style={{
        width: LHSWidth,
        height: '90vh',
        display: code.shouldHideCssEditor ? 'none' : 'block',
      }}
      editorDidMount={handleCssEditorDidMount}
      extensions={[
        css(),
        cssLinter,
        cssTheme,
        readOnlyRangeDecoration(),
        initReadOnlyRangesExtension(),
      ]}
      onEditorChangeCallback={(view) => {
        updateIFrame(
          actualIFrameRef,
          {
            css: view.state.doc.toString(),
            html: htmlEditorRef.current?.state.doc.toString() || '',
          },
          code
        )

        updateLocalStorageValueOnDebounce(view)
      }}
      ref={cssEditorRef}
    />
  )
}
