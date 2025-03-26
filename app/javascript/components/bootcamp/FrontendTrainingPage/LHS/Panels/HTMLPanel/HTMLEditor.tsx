import React, { useContext } from 'react'
import { SimpleCodeMirror } from '../../../SimpleCodeMirror/SimpleCodeMirror'
import { useFrontendTrainingPageStore } from '../../../store/frontendTrainingPageStore'
import { FrontendTrainingPageContext } from '../../../FrontendTrainingPageContext'

export function HTMLEditor() {
  const { handleHtmlEditorDidMount, htmlEditorRef } = useContext(
    FrontendTrainingPageContext
  )
  const {
    panelSizes: { LHSWidth },
  } = useFrontendTrainingPageStore()

  return (
    <SimpleCodeMirror
      style={{ width: LHSWidth }}
      ref={htmlEditorRef}
      editorDidMount={handleHtmlEditorDidMount}
      extensions={[]}
      defaultCode="<div>hello</div>"
    />
  )
}
