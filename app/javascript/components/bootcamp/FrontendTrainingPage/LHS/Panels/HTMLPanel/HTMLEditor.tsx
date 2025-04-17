import React, { useContext } from 'react'
import { SimpleCodeMirror } from '../../../SimpleCodeMirror/SimpleCodeMirror'
import { useFrontendTrainingPageStore } from '../../../store/frontendTrainingPageStore'
import { FrontendTrainingPageContext } from '../../../FrontendTrainingPageContext'
import { html } from '@codemirror/lang-html'
import { updateIFrame } from '../../../utils/updateIFrame'

export function HTMLEditor() {
  const {
    handleHtmlEditorDidMount,
    htmlEditorRef,
    cssEditorRef,
    javaScriptEditorRef,
    setEditorCodeLocalStorage,
    actualIFrameRef,
  } = useContext(FrontendTrainingPageContext)
  const {
    panelSizes: { LHSWidth },
  } = useFrontendTrainingPageStore()

  return (
    <SimpleCodeMirror
      style={{ width: LHSWidth, height: '90vh' }}
      ref={htmlEditorRef}
      editorDidMount={handleHtmlEditorDidMount}
      onEditorChangeCallback={(view) => {
        setEditorCodeLocalStorage((prev) => ({
          ...prev,
          htmlEditorContent: view.state.doc.toString(),
        }))

        updateIFrame(actualIFrameRef, {
          html: view.state.doc.toString(),
          css: cssEditorRef.current?.state.doc.toString(),
          javascript: javaScriptEditorRef.current?.state.doc.toString(),
        })
      }}
      extensions={[html()]}
      defaultCode="<div>hello</div>"
    />
  )
}
