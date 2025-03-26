import React, { useContext } from 'react'
import { SimpleCodeMirror } from '../../../SimpleCodeMirror/SimpleCodeMirror'
import { FrontendTrainingPageContext } from '../../../FrontendTrainingPageContext'

export function CSSEditor() {
  const { LHSWidth, handleCssEditorDidMount } = useContext(
    FrontendTrainingPageContext
  )
  return (
    <SimpleCodeMirror
      style={{ width: LHSWidth }}
      editorDidMount={handleCssEditorDidMount}
      extensions={[]}
    />
  )
}
