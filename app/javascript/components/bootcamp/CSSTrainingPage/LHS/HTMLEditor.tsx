import React, { useContext } from 'react'
import { html } from '@codemirror/lang-html'
import { CSSTrainingPageContext } from '../CSSTrainingPageContext'
import { htmlLinter } from '../extensions/htmlLinter'
import { SimpleCodeMirror } from '../SimpleCodeMirror/SimpleCodeMirror'
import { useCSSTrainingPageStore } from '../store/cssTrainingPageStore'
import { updateIFrame } from '../utils/updateIFrame'

export function HTMLEditor() {
  const {
    handleHtmlEditorDidMount,
    htmlEditorRef,
    cssEditorRef,
    javaScriptEditorRef,
    setEditorCodeLocalStorage,
    actualIFrameRef,
  } = useContext(CSSTrainingPageContext)
  const {
    panelSizes: { LHSWidth },
  } = useCSSTrainingPageStore()

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
      extensions={[html(), htmlLinter]}
      defaultCode="<div>hello</div>"
    />
  )
}
