import React, { useContext } from 'react'
import { SimpleCodeMirror } from '../../../SimpleCodeMirror/SimpleCodeMirror'
import { useFrontendTrainingPageStore } from '../../../store/frontendTrainingPageStore'
import { FrontendTrainingPageContext } from '../../../FrontendTrainingPageContext'

export function HTMLEditor() {
  const { handleHtmlEditorDidMount, htmlEditorRef, setEditorCodeLocalStorage } =
    useContext(FrontendTrainingPageContext)
  const {
    panelSizes: { LHSWidth },
  } = useFrontendTrainingPageStore()

  return (
    <SimpleCodeMirror
      style={{ width: LHSWidth }}
      ref={htmlEditorRef}
      editorDidMount={handleHtmlEditorDidMount}
      onEditorChangeCallback={(view) => {
        setEditorCodeLocalStorage((prev) => ({
          ...prev,
          htmlEditorContent: view.state.doc.toString(),
        }))
      }}
      extensions={[]}
      defaultCode="<div>hello</div>"
    />
  )
}
