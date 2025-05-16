import React from 'react'
import { Toaster } from 'react-hot-toast'
import { Resizer } from '../JikiscriptExercisePage/hooks/useResize'
import { Header } from './Header/Header'
import { FrontendExercisePageContext } from './FrontendExercisePageContext'
import { useInitResizablePanels } from './hooks/useInitResizablePanels'
import { useSetupEditors } from './hooks/useSetupEditors'
import { useSetupIFrames } from './hooks/useSetupIFrames'
import { LHS } from './LHS/LHS'
import { RHS } from './RHS/RHS'

export default function FrontendExercisePage(data: FrontendExercisePageProps) {
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
    resetEditors,
  } = useSetupEditors(data.exercise.slug, data.code, actualIFrameRef)

  return (
    <FrontendExercisePageContext.Provider
      value={{
        actualIFrameRef,
        htmlEditorRef: htmlEditorViewRef,
        cssEditorRef: cssEditorViewRef,
        jsEditorRef: jsEditorViewRef,
        handleCssEditorDidMount,
        handleHtmlEditorDidMount,
        handleJsEditorDidMount,
        setEditorCodeLocalStorage,
        links: data.links,
        resetEditors,
      }}
    >
      <div id="bootcamp-frontend-exercise-page">
        <Header />
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
    </FrontendExercisePageContext.Provider>
  )
}
