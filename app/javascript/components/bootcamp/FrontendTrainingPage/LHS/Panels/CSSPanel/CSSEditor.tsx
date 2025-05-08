import React, { useContext } from 'react'
import { SimpleCodeMirror } from '../../../SimpleCodeMirror/SimpleCodeMirror'
import { FrontendTrainingPageContext } from '../../../FrontendTrainingPageContext'
import { useFrontendTrainingPageStore } from '../../../store/frontendTrainingPageStore'
import { css } from '@codemirror/lang-css'
import { updateIFrame } from '../../../utils/updateIFrame'
import { EDITOR_HEIGHT } from '../Panels'
import { interactionExtension } from '@/components/bootcamp/CSSExercisePage/SimpleCodeMirror/extensions/interaction/interaction'

export function CSSEditor() {
  const {
    cssEditorRef,
    htmlEditorRef,
    jsEditorRef,
    handleCssEditorDidMount,
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
      editorDidMount={handleCssEditorDidMount}
      extensions={[css(), interactionExtension()]}
      onEditorChangeCallback={(view) => {
        setEditorCodeLocalStorage((prev) => ({
          ...prev,
          cssEditorContent: view.state.doc.toString(),
        }))

        updateIFrame(actualIFrameRef, {
          css: view.state.doc.toString(),
          html: htmlEditorRef.current?.state.doc.toString(),
          js: jsEditorRef.current?.state.doc.toString(),
        })
      }}
      ref={cssEditorRef}
    />
  )
}
