import React, { useContext } from 'react'
import { SimpleCodeMirror } from '../../../SimpleCodeMirror/SimpleCodeMirror'
import { FrontendTrainingPageContext } from '../../../FrontendTrainingPageContext'
import { useFrontendTrainingPageStore } from '../../../store/frontendTrainingPageStore'
import { css } from '@codemirror/lang-css'
import { updateIFrame } from '../../../utils/updateIFrame'
import { cssLinter } from '../../../extensions/cssLinter'

export function CSSEditor() {
  const {
    cssEditorRef,
    htmlEditorRef,
    javaScriptEditorRef,
    handleCssEditorDidMount,
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
      editorDidMount={handleCssEditorDidMount}
      extensions={[css(), cssLinter]}
      onEditorChangeCallback={(view) => {
        setEditorCodeLocalStorage((prev) => ({
          ...prev,
          cssEditorContent: view.state.doc.toString(),
        }))

        updateIFrame(actualIFrameRef, {
          css: view.state.doc.toString(),
          html: htmlEditorRef.current?.state.doc.toString(),
          javascript: javaScriptEditorRef.current?.state.doc.toString(),
        })
      }}
      ref={cssEditorRef}
    />
  )
}
