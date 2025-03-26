import React, { useContext } from 'react'
import { SimpleCodeMirror } from '../../../SimpleCodeMirror/SimpleCodeMirror'
import { FrontendTrainingPageContext } from '../../../FrontendTrainingPageContext'
import { useFrontendTrainingPageStore } from '../../../store/frontendTrainingPageStore'

export function JavaScriptEditor() {
  const {
    javaScriptEditorRef,
    handleJavaScriptEditorDidMount,
    setEditorCodeLocalStorage,
  } = useContext(FrontendTrainingPageContext)
  const {
    panelSizes: { LHSWidth },
  } = useFrontendTrainingPageStore()

  return (
    <SimpleCodeMirror
      defaultCode=""
      style={{ width: LHSWidth }}
      editorDidMount={handleJavaScriptEditorDidMount}
      onEditorChangeCallback={(view) => {
        setEditorCodeLocalStorage((prev) => ({
          ...prev,
          javaScriptEditorContent: view.state.doc.toString(),
        }))
      }}
      ref={javaScriptEditorRef}
    />
  )
}
