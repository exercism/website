import React, { useContext, useMemo } from 'react'
import { FrontendExercisePageContext } from '../../../FrontendExercisePageContext'
import { useFrontendExercisePageStore } from '../../../store/frontendExercisePageStore'
import { css } from '@codemirror/lang-css'
import { updateIFrame } from '../../../utils/updateIFrame'
import { EDITOR_HEIGHT } from '../Panels'
import { interactionExtension } from '@/components/bootcamp/CSSExercisePage/SimpleCodeMirror/extensions/interaction/interaction'
import { SimpleCodeMirror } from '@/components/bootcamp/CSSExercisePage/SimpleCodeMirror/SimpleCodeMirror'
import { createUpdateLocalStorageValueOnDebounce } from '../utils/updateLocalStorageValueOnDebounce'
import {
  readOnlyRangeDecoration,
  initReadOnlyRangesExtension,
} from '@/components/bootcamp/JikiscriptExercisePage/CodeMirror/extensions'
import { moveCursorByPasteLength } from '@/components/bootcamp/JikiscriptExercisePage/CodeMirror/extensions/move-cursor-by-paste-length'
import { cssTheme } from '@/components/bootcamp/CSSExercisePage/LHS/cssTheme'

export function CSSEditor() {
  const {
    cssEditorRef,
    htmlEditorRef,
    jsEditorRef,
    handleCssEditorDidMount,
    setEditorCodeLocalStorage,
    actualIFrameRef,
    code,
    defaultCode,
  } = useContext(FrontendExercisePageContext)
  const {
    panelSizes: { LHSWidth },
  } = useFrontendExercisePageStore()

  const updateLocalStorageValueOnDebounce = useMemo(() => {
    return createUpdateLocalStorageValueOnDebounce()
  }, [setEditorCodeLocalStorage])

  return (
    <SimpleCodeMirror
      defaultCode={defaultCode.css}
      style={{ width: LHSWidth, height: EDITOR_HEIGHT }}
      editorDidMount={handleCssEditorDidMount}
      extensions={[
        moveCursorByPasteLength,
        css(),
        cssTheme,
        interactionExtension(),
        readOnlyRangeDecoration(),
        initReadOnlyRangesExtension(),
      ]}
      onEditorChangeCallback={(view) => {
        updateLocalStorageValueOnDebounce(
          {
            cssEditor: view,
            htmlEditor: htmlEditorRef.current,
            jsEditor: jsEditorRef.current,
          },
          setEditorCodeLocalStorage
        )

        updateIFrame(
          actualIFrameRef,
          {
            css: view.state.doc.toString(),
            html: htmlEditorRef.current?.state.doc.toString(),
            script: '',
          },
          code
        )
      }}
      ref={cssEditorRef}
    />
  )
}
