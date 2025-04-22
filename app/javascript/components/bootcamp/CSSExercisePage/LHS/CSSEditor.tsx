import React, { useContext } from 'react'
import { css } from '@codemirror/lang-css'
import { cssLinter } from '../SimpleCodeMirror/extensions/cssLinter'
import { CSSExercisePageContext } from '../CSSExercisePageContext'
import { SimpleCodeMirror } from '../SimpleCodeMirror/SimpleCodeMirror'
import { useCSSExercisePageStore } from '../store/cssExercisePageStore'
import { updateIFrame } from '../utils/updateIFrame'

export function CSSEditor() {
  const {
    cssEditorRef,
    htmlEditorRef,
    handleCssEditorDidMount,
    setEditorCodeLocalStorage,
    actualIFrameRef,
    code,
  } = useContext(CSSExercisePageContext)
  const {
    panelSizes: { LHSWidth },
  } = useCSSExercisePageStore()

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

        const css = code.default.css + view.state.doc.toString()
        updateIFrame(actualIFrameRef, {
          css,
          html: htmlEditorRef.current?.state.doc.toString(),
        })
      }}
      ref={cssEditorRef}
    />
  )
}
