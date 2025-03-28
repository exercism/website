import React, { useContext } from 'react'
import { html } from '@codemirror/lang-html'
import { CSSExercisePageContext } from '../CSSExercisePageContext'
import { htmlLinter } from '../SimpleCodeMirror/extensions/htmlLinter'
import { SimpleCodeMirror } from '../SimpleCodeMirror/SimpleCodeMirror'
import { useCSSExercisePageStore } from '../store/cssExercisePageStore'
import { updateIFrame } from '../utils/updateIFrame'

export function HTMLEditor() {
  const {
    handleHtmlEditorDidMount,
    htmlEditorRef,
    cssEditorRef,
    setEditorCodeLocalStorage,
    actualIFrameRef,
  } = useContext(CSSExercisePageContext)
  const {
    panelSizes: { LHSWidth },
  } = useCSSExercisePageStore()

  return (
    <SimpleCodeMirror
      style={{ width: LHSWidth, height: '90vh' }}
      ref={htmlEditorRef}
      editorDidMount={handleHtmlEditorDidMount}
      onEditorChangeCallback={(view) => {
        setEditorCodeLocalStorage((prev) => ({
          ...prev,
          htmlEditorContent: view.state.doc.toString(),
        }))

        updateIFrame(actualIFrameRef, {
          html: view.state.doc.toString(),
          css: cssEditorRef.current?.state.doc.toString(),
        })
      }}
      extensions={[html(), htmlLinter]}
      defaultCode="<div>hello</div>"
    />
  )
}
