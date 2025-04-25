import React, { useContext } from 'react'
import { css } from '@codemirror/lang-css'
import { cssLinter } from '../SimpleCodeMirror/extensions/cssLinter'
import { CSSExercisePageContext } from '../CSSExercisePageContext'
import { SimpleCodeMirror } from '../SimpleCodeMirror/SimpleCodeMirror'
import { useCSSExercisePageStore } from '../store/cssExercisePageStore'

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
      style={{
        width: LHSWidth,
        height: '90vh',
        display: code.shouldHideCssEditor ? 'none' : 'block',
      }}
      editorDidMount={handleCssEditorDidMount}
      extensions={[css(), cssLinter]}
      onEditorChangeCallback={(view) => {
        setEditorCodeLocalStorage((prev) => {
          return {
            ...prev,
            cssEditorContent: view.state.doc.toString(),
            htmlEditorContent:
              htmlEditorRef.current?.state.doc.toString() || '',
            storedAt: new Date().toISOString(),
          }
        })
      }}
      ref={cssEditorRef}
    />
  )
}
