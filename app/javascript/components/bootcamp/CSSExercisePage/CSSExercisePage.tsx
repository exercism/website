import React from 'react'
import { Resizer } from '../JikiscriptExercisePage/hooks/useResize'
import { Toaster } from 'react-hot-toast'
import { Header } from './Header'
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
  } = useSetupIFrames()

  useLogger('CSSExercisePage', data)

  const { handleWidthChangeMouseDown } = useInitResizablePanels()

  const {
    htmlEditorViewRef,
    cssEditorViewRef,
    handleCssEditorDidMount,
    handleHtmlEditorDidMount,
    setEditorCodeLocalStorage,
  } = useSetupEditors(data.exercise.slug)

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
    </CSSExercisePageContext.Provider>
  )
}
