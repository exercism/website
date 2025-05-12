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

export function HTMLEditor() {
  const {
    handleHtmlEditorDidMount,
    htmlEditorRef,
    cssEditorRef,
    jsEditorRef,
    setEditorCodeLocalStorage,
    actualIFrameRef,
  } = useContext(FrontendExercisePageContext)
  const {
    panelSizes: { LHSWidth },
  } = useFrontendExercisePageStore()

  const updateLocalStorageValueOnDebounce = useMemo(() => {
    return createUpdateLocalStorageValueOnDebounce()
  }, [setEditorCodeLocalStorage])

  return (
    <SimpleCodeMirror
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

        updateIFrame(actualIFrameRef, {
          html: view.state.doc.toString(),
          css: cssEditorRef.current?.state.doc.toString(),
          js: jsEditorRef.current?.state.doc.toString(),
        })
      }}
      extensions={[
        html(),
        readOnlyRangeDecoration(),
        initReadOnlyRangesExtension(),
      ]}
      defaultCode="<div>hello</div>"
    />
  )
}
