import React, { useContext, useMemo } from 'react'
import { useFrontendExercisePageStore } from '../../../store/frontendExercisePageStore'
import { FrontendExercisePageContext } from '../../../FrontendExercisePageContext'
import { html } from '@codemirror/lang-html'
import { updateIFrame } from '../../../utils/updateIFrame'
import { EDITOR_HEIGHT } from '../Panels'
import { SimpleCodeMirror } from '@/components/bootcamp/CSSExercisePage/SimpleCodeMirror/SimpleCodeMirror'
import { createUpdateLocalStorageValueOnDebounce } from '../utils/updateLocalStorageValueOnDebounce'
import {
  readOnlyRangeDecoration,
  initReadOnlyRangesExtension,
} from '@/components/bootcamp/JikiscriptExercisePage/CodeMirror/extensions'
import { moveCursorByPasteLength } from '@/components/bootcamp/JikiscriptExercisePage/CodeMirror/extensions/move-cursor-by-paste-length'
import {
  htmlLinter,
  lintTooltipTheme,
} from '@/components/bootcamp/CSSExercisePage/SimpleCodeMirror/extensions/htmlLinter'
import { htmlTheme } from '@/components/bootcamp/CSSExercisePage/LHS/htmlTheme'
import { EditorView } from 'codemirror'

export function HTMLEditor() {
  const {
    handleHtmlEditorDidMount,
    htmlEditorRef,
    cssEditorRef,
    jsEditorRef,
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
      defaultCode={defaultCode.html}
      style={{ width: LHSWidth, height: EDITOR_HEIGHT }}
      ref={htmlEditorRef}
      editorDidMount={handleHtmlEditorDidMount}
      onEditorChangeCallback={(view) => {
        updateLocalStorageValueOnDebounce(
          {
            cssEditor: cssEditorRef.current,
            htmlEditor: view,
            jsEditor: jsEditorRef.current,
          },
          setEditorCodeLocalStorage
        )

        updateIFrame(
          actualIFrameRef,
          {
            html: view.state.doc.toString(),
            css: cssEditorRef.current?.state.doc.toString(),
            script: '',
          },
          code
        )
      }}
      extensions={[
        moveCursorByPasteLength,
        html({ autoCloseTags: false }),
        htmlLinter,
        htmlTheme,
        lintTooltipTheme,
        readOnlyRangeDecoration(),
        initReadOnlyRangesExtension(),
      ]}
    />
  )
}
