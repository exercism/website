import React, { useContext } from 'react'
import { SimpleCodeMirror } from '../../../SimpleCodeMirror/SimpleCodeMirror'
import { FrontendTrainingPageContext } from '../../../FrontendTrainingPageContext'
import { useFrontendTrainingPageStore } from '../../../store/frontendTrainingPageStore'
import { CodeMirror } from '@/components/bootcamp/SolveExercisePage/CodeMirror/CodeMirror'

export function JavaScriptEditor() {
  const { javaScriptEditorRef, handleJavaScriptEditorDidMount } = useContext(
    FrontendTrainingPageContext
  )
  const {
    panelSizes: { LHSWidth },
  } = useFrontendTrainingPageStore()
  return (
    <SimpleCodeMirror
      defaultCode=""
      style={{ width: LHSWidth }}
      editorDidMount={handleJavaScriptEditorDidMount}
      ref={javaScriptEditorRef}
    />
  )
}
