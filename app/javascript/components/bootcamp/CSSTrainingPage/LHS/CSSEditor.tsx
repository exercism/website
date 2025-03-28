import React, { useContext } from 'react'
import { css } from '@codemirror/lang-css'
import { cssLinter } from '../extensions/cssLinter'
import { CSSTrainingPageContext } from '../CSSExercisePageContext'
import { SimpleCodeMirror } from '../SimpleCodeMirror/SimpleCodeMirror'
import { useCSSTrainingPageStore } from '../store/cssExercisePageStore'
import { updateIFrame } from '../utils/updateIFrame'

export function CSSEditor() {
  const {
    cssEditorRef,
    htmlEditorRef,
    javaScriptEditorRef,
    handleCssEditorDidMount,
    setEditorCodeLocalStorage,
    actualIFrameRef,
  } = useContext(CSSTrainingPageContext)
  const {
    panelSizes: { LHSWidth },
  } = useCSSTrainingPageStore()

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
