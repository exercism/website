import React, { useContext } from 'react'
import { SimpleCodeMirror } from '../../../SimpleCodeMirror/SimpleCodeMirror'
import { FrontendTrainingPageContext } from '../../../FrontendTrainingPageContext'
import { useFrontendTrainingPageStore } from '../../../store/frontendTrainingPageStore'
import { javascript } from '@codemirror/lang-javascript'
import { updateIFrame } from '../../../utils/updateIFrame'

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
      style={{ width: LHSWidth, height: '90vh' }}
      editorDidMount={handleJavaScriptEditorDidMount}
      extensions={[javascript()]}
      onEditorChangeCallback={(view) => {
        setEditorCodeLocalStorage((prev) => ({
          ...prev,
          javaScriptEditorContent: view.state.doc.toString(),
        }))

        updateIFrame(actualIFrameRef, {
          javascript: view.state.doc.toString(),
          html: htmlEditorRef.current?.state.doc.toString(),
          css: cssEditorRef.current?.state.doc.toString(),
        })
      }}
      ref={javaScriptEditorRef}
    />
  )
}
