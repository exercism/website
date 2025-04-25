import React, { useContext } from 'react'
import { html } from '@codemirror/lang-html'
import { CSSExercisePageContext } from '../CSSExercisePageContext'
import { htmlLinter } from '../SimpleCodeMirror/extensions/htmlLinter'
import { SimpleCodeMirror } from '../SimpleCodeMirror/SimpleCodeMirror'
import { useCSSExercisePageStore } from '../store/cssExercisePageStore'

export function HTMLEditor() {
  const {
    handleHtmlEditorDidMount,
    htmlEditorRef,
    cssEditorRef,
    setEditorCodeLocalStorage,
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
          cssEditorContent: cssEditorRef.current?.state.doc.toString() || '',
        }))
      }}
      extensions={[html(), htmlLinter]}
      defaultCode="<div>hello</div>"
    />
  )
}
