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
    javaScriptEditorViewRef,
    handleCssEditorDidMount,
    handleHtmlEditorDidMount,
    handleJavaScriptEditorDidMount,
    setEditorCodeLocalStorage,
    // TODO: ADD EXERCISE UUID HERE
  } = useSetupEditors()

  return (
    <FrontendTrainingPageContext.Provider
      value={{
        actualIFrameRef,
        htmlEditorRef: htmlEditorViewRef,
        cssEditorRef: cssEditorViewRef,
        javaScriptEditorRef: javaScriptEditorViewRef,
        handleCssEditorDidMount,
        handleHtmlEditorDidMount,
        handleJavaScriptEditorDidMount,
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
