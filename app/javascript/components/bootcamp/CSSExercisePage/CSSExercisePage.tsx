import React from 'react'
import { Toaster } from 'react-hot-toast'
import { Resizer } from '../JikiscriptExercisePage/hooks/useResize'
import { Header } from './Header/Header'
import { useInitResizablePanels } from './hooks/useInitResizablePanels'
import { useSetupEditors } from './hooks/useSetupEditors'
import { useSetupIFrames } from './hooks/useSetupIFrames'
import { LHS } from './LHS/LHS'
import { RHS } from './RHS/RHS'
import { CSSExercisePageContext } from './CSSExercisePageContext'
import { useLogger } from '../common/hooks/useLogger'

export default function CSSExercisePage(data: CSSExercisePageProps) {
  const {
    actualIFrameRef,
    expectedIFrameRef,
    expectedReferenceIFrameRef,
    handleCompare,
  } = useSetupIFrames(data.exercise.config, data.code)

  useLogger('CSSExercisePage', data)

  const { handleWidthChangeMouseDown } = useInitResizablePanels()

  const {
    htmlEditorViewRef,
    cssEditorViewRef,
    handleCssEditorDidMount,
    handleHtmlEditorDidMount,
    setEditorCodeLocalStorage,
    resetEditors,
    getEditorValues,
  } = useSetupEditors(data.exercise.slug, data.code, actualIFrameRef)

  return (
    <CSSExercisePageContext.Provider
      value={{
        actualIFrameRef,
        expectedIFrameRef,
        expectedReferenceIFrameRef,
        htmlEditorRef: htmlEditorViewRef,
        cssEditorRef: cssEditorViewRef,
        handleCssEditorDidMount,
        handleHtmlEditorDidMount,
        setEditorCodeLocalStorage,
        resetEditors,
        handleCompare,
        exercise: data.exercise,
        code: data.code,
        links: data.links,
        solution: data.solution,
      }}
    >
      <div id="bootcamp-frontend-training-page">
        <Header />
        <div className="page-body">
          <LHS getEditorValues={getEditorValues} />
          <Resizer
            direction="vertical"
            handleMouseDown={handleWidthChangeMouseDown}
          />
          <RHS />
        </div>
      </div>
      <Toaster />
    </CSSExercisePageContext.Provider>
  )
}
