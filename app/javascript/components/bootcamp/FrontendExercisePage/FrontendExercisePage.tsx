import React, { useEffect } from 'react'
import { Toaster } from 'react-hot-toast'
import { Resizer } from '../JikiscriptExercisePage/hooks/useResize'
import { Header } from './Header/Header'
import { FrontendExercisePageContext } from './FrontendExercisePageContext'
import { useInitResizablePanels } from './hooks/useInitResizablePanels'
import { useSetupEditors } from './hooks/useSetupEditors'
import { useSetupIFrames } from './hooks/useSetupIFrames'
import { LHS } from './LHS/LHS'
import { RHS } from './RHS/RHS'
import { useRestoreIframeScrollAfterResize } from './hooks/useRestoreIframeScrollAfterResize'

export default function FrontendExercisePage(data: FrontendExercisePageProps) {
  const { actualIFrameRef, expectedIFrameRef, expectedReferenceIFrameRef } =
    useSetupIFrames(data.exercise.config, data.code)

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
    defaultCode,
  } = useSetupEditors(data.exercise.slug, data.code, actualIFrameRef)

  const jsCodeRunId = React.useRef(0)

  useRestoreIframeScrollAfterResize()

  return (
    <FrontendExercisePageContext.Provider
      value={{
        actualIFrameRef,
        expectedIFrameRef,
        expectedReferenceIFrameRef,
        htmlEditorRef: htmlEditorViewRef,
        cssEditorRef: cssEditorViewRef,
        jsEditorRef: jsEditorViewRef,
        jsCodeRunId,
        handleCssEditorDidMount,
        handleHtmlEditorDidMount,
        handleJsEditorDidMount,
        setEditorCodeLocalStorage,
        links: data.links,
        exercise: data.exercise,
        code: data.code,
        solution: data.solution,
        resetEditors,
        defaultCode,
      }}
    >
      <div id="bootcamp-frontend-exercise-page">
        <Header />
        <div className="page-body">
          <LHS />
          <Resizer
            className="frontend-exercise-page-resizer"
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
