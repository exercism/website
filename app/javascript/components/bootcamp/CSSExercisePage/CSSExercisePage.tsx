import React, { useEffect } from 'react'
import { Toaster } from 'react-hot-toast'
import { Resizer } from '../JikiscriptExercisePage/hooks/useResize'
import { Header } from './Header/Header'
import { useInitResizablePanels } from './hooks/useInitResizablePanels'
import { useSetupEditors } from './hooks/useSetupEditors'
import { useSetupIFrames } from './hooks/useSetupIFrames'
import { LHS } from './LHS/LHS'
import { RHS } from './RHS/RHS'
import { CSSExercisePageContext } from './CSSExercisePageContext'
import { useCSSExercisePageStore } from './store/cssExercisePageStore'

export default function CSSExercisePage(data: CSSExercisePageProps) {
  const {
    actualIFrameRef,
    expectedIFrameRef,
    expectedReferenceIFrameRef,
    handleCompare,
  } = useSetupIFrames(data.exercise.config, data.code)

  const { setAssertionStatus } = useCSSExercisePageStore()

  useEffect(() => {
    if (data.solution.passedBasicTests) {
      setAssertionStatus('pass')
    }
  }, [data.solution])

  const { handleWidthChangeMouseDown } = useInitResizablePanels()

  const {
    htmlEditorViewRef,
    cssEditorViewRef,
    handleCssEditorDidMount,
    handleHtmlEditorDidMount,
    setEditorCodeLocalStorage,
    resetEditors,
    getEditorValues,
    defaultCode,
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
          <LHS defaultCode={defaultCode} getEditorValues={getEditorValues} />
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
