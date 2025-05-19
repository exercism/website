import React, { useContext, useMemo } from 'react'
import { html } from '@codemirror/lang-html'
import { CSSExercisePageContext } from '../CSSExercisePageContext'
import {
  htmlLinter,
  lintTooltipTheme,
} from '../SimpleCodeMirror/extensions/htmlLinter'
import { SimpleCodeMirror } from '../SimpleCodeMirror/SimpleCodeMirror'
import { useCSSExercisePageStore } from '../store/cssExercisePageStore'
import { EditorView } from 'codemirror'
import { debounce } from 'lodash'
import {
  initReadOnlyRangesExtension,
  readOnlyRangesStateField,
} from '../../JikiscriptExercisePage/CodeMirror/extensions/read-only-ranges/readOnlyRanges'
import { getCodeMirrorFieldValue } from '../../JikiscriptExercisePage/CodeMirror/getCodeMirrorFieldValue'
import { updateIFrame } from '../utils/updateIFrame'
import { readOnlyRangeDecoration } from '../../JikiscriptExercisePage/CodeMirror/extensions'
import { htmlTheme } from './htmlTheme'
import { moveCursorByPasteLength } from '../../JikiscriptExercisePage/CodeMirror/extensions/move-cursor-by-paste-length'
import XXH from 'xxhashjs'

export function HTMLEditor({ defaultCode }: { defaultCode: string }) {
  const {
    handleHtmlEditorDidMount,
    htmlEditorRef,
    cssEditorRef,
    code,
    setEditorCodeLocalStorage,
    actualIFrameRef,
  } = useContext(CSSExercisePageContext)
  const {
    panelSizes: { LHSWidth },
    setStudentCodeHash,
  } = useCSSExercisePageStore()

  const updateLocalStorageValueOnDebounce = useMemo(() => {
    return debounce((view: EditorView) => {
      if (!setEditorCodeLocalStorage) {
        return
      }

      const htmlReadonlyRanges = getCodeMirrorFieldValue(
        view,
        readOnlyRangesStateField
      )

      const cssReadonlyRanges = getCodeMirrorFieldValue(
        cssEditorRef.current,
        readOnlyRangesStateField
      )

      setEditorCodeLocalStorage({
        cssEditorContent: cssEditorRef.current?.state.doc.toString() || '',
        htmlEditorContent: view.state.doc.toString(),
        storedAt: new Date().toISOString(),
        readonlyRanges: {
          css: cssReadonlyRanges,
          html: htmlReadonlyRanges,
        },
      })
    }, 500)
  }, [setEditorCodeLocalStorage, readOnlyRangesStateField])

  const updateEditorHashOnDebounce = useMemo(() => {
    return debounce((view: EditorView) => {
      const htmlContent = view.state.doc.toString()
      const cssContent = cssEditorRef.current?.state.doc.toString() || ''

      const hash = XXH.h32(htmlContent + cssContent, 0).toString(16)

      setStudentCodeHash(hash)
    }, 500)
  }, [setEditorCodeLocalStorage, readOnlyRangesStateField])

  return (
    <SimpleCodeMirror
      style={{
        width: LHSWidth,
        height: '90vh',
        display: code.shouldHideHtmlEditor ? 'none' : 'block',
      }}
      ref={htmlEditorRef}
      editorDidMount={handleHtmlEditorDidMount}
      extensions={[
        moveCursorByPasteLength,
        html({
          autoCloseTags: false,
        }),
        htmlTheme,
        lintTooltipTheme,
        htmlLinter,
        readOnlyRangeDecoration(),
        initReadOnlyRangesExtension(),
      ]}
      onEditorChangeCallback={(view) => {
        updateIFrame(
          actualIFrameRef,
          {
            html: view.state.doc.toString(),
            css: cssEditorRef.current?.state.doc.toString() || '',
          },
          code
        )

        updateLocalStorageValueOnDebounce(view)
        updateEditorHashOnDebounce(view)
      }}
      defaultCode={defaultCode}
    />
  )
}
