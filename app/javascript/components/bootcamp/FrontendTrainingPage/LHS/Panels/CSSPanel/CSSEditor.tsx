import React, { useContext } from 'react'
import { SimpleCodeMirror } from '../../../SimpleCodeMirror/SimpleCodeMirror'
import { FrontendTrainingPageContext } from '../../../FrontendTrainingPageContext'
import { useFrontendTrainingPageStore } from '../../../store/frontendTrainingPageStore'

export function CSSEditor() {
  const { cssEditorRef, handleCssEditorDidMount } = useContext(
    FrontendTrainingPageContext
  )
  const {
    panelSizes: { LHSWidth },
  } = useFrontendTrainingPageStore()
  return (
    <SimpleCodeMirror
      defaultCode=""
      style={{ width: LHSWidth }}
      editorDidMount={handleCssEditorDidMount}
      ref={cssEditorRef}
    />
  )
}
