import React from 'react'
import { Resizer } from '../JikiscriptExercisePage/hooks/useResize'
import { Toaster } from 'react-hot-toast'
import { Header } from './Header'
import { FrontendTrainingPageContext } from './FrontendTrainingPageContext'
import { useInitResizablePanels } from './hooks/useInitResizablePanels'
import { useSetupEditors } from './hooks/useSetupEditors'
import { useSetupIFrames } from './hooks/useSetupIFrames'
import { LHS } from './LHS/LHS'
import { RHS } from './RHS/RHS'

export default function FrontendTrainingPage() {
  const {
    actualIFrameRef,
    expectedIFrameRef,
    expectedReferenceIFrameRef,
    handleCompare,
  } = useSetupIFrames()

  const { handleWidthChangeMouseDown } = useInitResizablePanels()

  const {
    htmlEditorViewRef,
    cssEditorViewRef,
    javaScriptEditorViewRef,
    handleCssEditorDidMount,
    handleHtmlEditorDidMount,
    handleJavaScriptEditorDidMount,
    setEditorCodeLocalStorage,
  } = useSetupEditors()

  return (
    <FrontendTrainingPageContext.Provider
      value={{
        actualIFrameRef,
        expectedIFrameRef,
        expectedReferenceIFrameRef,
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
        <Header onCompare={handleCompare} />
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
