import React, { useContext } from 'react'
import { FrontendTrainingPageContext } from '../../../FrontendTrainingPageContext'
import { useFrontendTrainingPageStore } from '../../../store/frontendTrainingPageStore'
import { javascript } from '@codemirror/lang-javascript'
import { updateIFrame } from '../../../utils/updateIFrame'
import { EDITOR_HEIGHT } from '../Panels'
import { SimpleCodeMirror } from '@/components/bootcamp/CSSExercisePage/SimpleCodeMirror/SimpleCodeMirror'
import { jsTheme } from '@/components/bootcamp/JikiscriptExercisePage/CodeMirror/extensions'
import { eslintLinter } from '@/components/bootcamp/CSSExercisePage/SimpleCodeMirror/extensions/eslinter'

export function JavaScriptEditor() {
  const {
    jsEditorRef,
    htmlEditorRef,
    cssEditorRef,
    handleJsEditorDidMount,
    setEditorCodeLocalStorage,
    actualIFrameRef,
  } = useContext(FrontendTrainingPageContext)
  const {
    panelSizes: { LHSWidth },
  } = useFrontendTrainingPageStore()

  return (
    <SimpleCodeMirror
      defaultCode=""
      style={{ width: LHSWidth, height: EDITOR_HEIGHT }}
      editorDidMount={handleJsEditorDidMount}
      extensions={[javascript(), eslintLinter, jsTheme]}
      onEditorChangeCallback={(view) => {
        const doc = view.state.doc.toString()
        setEditorCodeLocalStorage((prev) => ({
          ...prev,
          jsEditorContent: doc,
        }))

        updateIFrame(actualIFrameRef, {
          js: doc,
          html: htmlEditorRef.current?.state.doc.toString(),
          css: cssEditorRef.current?.state.doc.toString(),
        })
      }}
      ref={jsEditorRef}
    />
  )
}
