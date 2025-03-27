import React, { useContext } from 'react'
import { SimpleCodeMirror } from '../../../SimpleCodeMirror/SimpleCodeMirror'
import { FrontendTrainingPageContext } from '../../../FrontendTrainingPageContext'
import { useFrontendTrainingPageStore } from '../../../store/frontendTrainingPageStore'
import { javascript } from '@codemirror/lang-javascript'
import { updateIFrame } from '../../../utils/updateIFrame'
import { eslintLinter } from '../../../extensions/eslinter'
import { EDITOR_HEIGHT } from '../Panels'

export function JavaScriptEditor() {
  const {
    javaScriptEditorRef,
    htmlEditorRef,
    cssEditorRef,
    handleJavaScriptEditorDidMount,
    setEditorCodeLocalStorage,
    actualIFrameRef,
  } = useContext(FrontendTrainingPageContext)
  const {
    panelSizes: { LHSWidth },
  } = useFrontendTrainingPageStore()

  return (
    <SimpleCodeMirror
      defaultCode=""
      style={{ width: LHSWidth, height: EDITOR_HEIGHT }}
      editorDidMount={handleJavaScriptEditorDidMount}
      extensions={[javascript(), eslintLinter]}
      onEditorChangeCallback={(view) => {
        const doc = view.state.doc.toString()
        setEditorCodeLocalStorage((prev) => ({
          ...prev,
          javaScriptEditorContent: doc,
        }))

        updateIFrame(actualIFrameRef, {
          javascript: doc,
          html: htmlEditorRef.current?.state.doc.toString(),
          css: cssEditorRef.current?.state.doc.toString(),
        })
      }}
      ref={javaScriptEditorRef}
    />
  )
}
