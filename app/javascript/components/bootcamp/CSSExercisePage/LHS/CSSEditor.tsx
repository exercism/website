import React, { useContext, useMemo } from 'react'
import { css } from '@codemirror/lang-css'
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
import { moveCursorByPasteLength } from '../../JikiscriptExercisePage/CodeMirror/extensions/move-cursor-by-paste-length'
import XXH from 'xxhashjs'
import { interactionExtension } from '../SimpleCodeMirror/extensions/interaction/interaction'

export function CSSEditor({ defaultCode }: { defaultCode: string }) {
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
    setStudentCodeHash,
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

  const updateEditorHashOnDebounce = useMemo(() => {
    return debounce((view: EditorView) => {
      const cssContent = view.state.doc.toString()
      const htmlContent = htmlEditorRef.current?.state.doc.toString() || ''

      const hash = XXH.h32(htmlContent + cssContent, 0).toString(16)

      setStudentCodeHash(hash)
    }, 500)
  }, [setEditorCodeLocalStorage, readOnlyRangesStateField])

  return (
    <SimpleCodeMirror
      defaultCode={defaultCode}
      style={{
        width: LHSWidth,
        height: '90vh',
        display: code.shouldHideCssEditor ? 'none' : 'block',
      }}
      editorDidMount={handleCssEditorDidMount}
      extensions={[
        moveCursorByPasteLength,
        css(),
        cssTheme,
        readOnlyRangeDecoration(),
        initReadOnlyRangesExtension(),
        interactionExtension(),
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
        updateEditorHashOnDebounce(view)
      }}
      ref={cssEditorRef}
    />
  )
}
