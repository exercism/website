import React from 'react'
import { Toaster } from 'react-hot-toast'
import { Resizer } from '../JikiscriptExercisePage/hooks/useResize'
import { Header } from './Header'
import { FrontendTrainingPageContext } from './FrontendTrainingPageContext'
import { useInitResizablePanels } from './hooks/useInitResizablePanels'
import { useSetupEditors } from './hooks/useSetupEditors'
import { useSetupIFrames } from './hooks/useSetupIFrames'
import { LHS } from './LHS/LHS'
import { RHS } from './RHS/RHS'

export default function FrontendTrainingPage() {
  const { actualIFrameRef } = useSetupIFrames()

  const { handleWidthChangeMouseDown } = useInitResizablePanels()

  const {
    htmlEditorViewRef,
    cssEditorViewRef,
    jsEditorViewRef,
    handleCssEditorDidMount,
    handleHtmlEditorDidMount,
    handleJsEditorDidMount,
    setEditorCodeLocalStorage,
    // TODO: ADD EXERCISE UUID HERE
  } = useSetupEditors(
    'slug',
    {
      // TODO: Pass down `code` once it exists
      stub: {
        html: '',
        css: '',
        js: '',
      },
      code: '',
      normalizeCss: '',
      default: {
        html: undefined,
        css: undefined,
        js: undefined,
      },
      shouldHideCssEditor: false,
      shouldHideHtmlEditor: false,
      aspectRatio: 0,
      storedAt: null,
    },
    actualIFrameRef
  )

  return (
    <FrontendTrainingPageContext.Provider
      value={{
        actualIFrameRef,
        htmlEditorRef: htmlEditorViewRef,
        cssEditorRef: cssEditorViewRef,
        jsEditorRef: jsEditorViewRef,
        handleCssEditorDidMount,
        handleHtmlEditorDidMount,
        handleJsEditorDidMount,
        setEditorCodeLocalStorage,
      }}
    >
      <div id="bootcamp-frontend-training-page">
        <Header onComplete={() => {}} />
        <div className="page-body">
          <LHS />
          <Resizer
            direction="vertical"
            handleMouseDown={handleWidthChangeMouseDown}
          />
          <RHS />
        </div>
      </div>
      <Toaster />
    </FrontendTrainingPageContext.Provider>
  )
}
