import React from 'react'
import { SimpleCodeMirror } from '../../../SimpleCodeMirror/SimpleCodeMirror'
import { useFrontendTrainingPageStore } from '../../../store/frontendTrainingPageStore'

export function HTMLEditor() {
  const [editorCode, setEditorCode] = useLocalStorage('frontend-editor-code', {
    htmlEditorContent: '',
    cssEditorContent: '',
  })
  const {
    editorViewRef: cssEditorViewRef,
    handleEditorDidMount: handleCssEditorDidMount,
  } = useEditorHandler(editorCode.cssEditorContent)

  return (
    <SimpleCodeMirror
      style={{ width: panelSizes.LHSWidth }}
      ref={}
      editorDidMount={handleHtmlEditorDidMount}
      extensions={[]}
      defaultCode="<div>hello</div>"
    />
  )
}
