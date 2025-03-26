import React, { useContext } from 'react'
import { SimpleCodeMirror } from '../../../SimpleCodeMirror/SimpleCodeMirror'
import { FrontendTrainingPageContext } from '../../../FrontendTrainingPageContext'

export function HTMLEditor() {
  const { LHSWidth, handleHtmlEditorDidMount } = useContext(
    FrontendTrainingPageContext
  )

  return (
    <SimpleCodeMirror
      style={{ width: LHSWidth }}
      editorDidMount={handleHtmlEditorDidMount}
      extensions={[]}
      defaultCode="<div>hello</div>"
    />
  )
}
