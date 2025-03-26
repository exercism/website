import React, { useRef } from 'react'
import { Resizer } from '../SolveExercisePage/hooks/useResize'
import { Toaster } from 'react-hot-toast'
import { Header } from './Header'
import { FrontendTrainingPageContext } from './FrontendTrainingPageContext'
import { useInitResizablePanels } from './hooks/useInitResizablePanels'
import { useSetupEditors } from './hooks/useSetupEditors'
import { useSetupIFrames } from './hooks/useSetupIFrames'
import { LHS } from './LHS/LHS'
import { ActualOutput } from './ActualOutput'
import { ExpectedOutput } from './ExpectedOutput'
import { Instructions } from './Instructions'
import { useFrontendTrainingPageStore } from './store/frontendTrainingPageStore'

export default function FrontendTrainingPage() {
  const actualOutputRef = useRef<HTMLDivElement>(null)
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
    handleCssEditorDidMount,
    handleHtmlEditorDidMount,
  } = useSetupEditors()

  const {
    panelSizes: { RHSWidth },
  } = useFrontendTrainingPageStore()

  return (
    <FrontendTrainingPageContext.Provider
      value={{
        actualIFrameRef,
        expectedIFrameRef,
        expectedReferenceIFrameRef,
        htmlEditorRef: htmlEditorViewRef,
        cssEditorRef: cssEditorViewRef,
        handleCssEditorDidMount,
        handleHtmlEditorDidMount,
      }}
    >
      <div id="bootcamp-front-end-training-page">
        <Header onCompare={handleCompare} />
        <div className="page-body">
          <LHS />
          <Resizer
            direction="vertical"
            handleMouseDown={handleWidthChangeMouseDown}
          />
          <div className="page-body-rhs" style={{ width: RHSWidth }}>
            <div className="flex flex-col gap-12">
              <div ref={actualOutputRef} />
              <ActualOutput />
              <ExpectedOutput />
            </div>
            <Instructions
              exerciseTitle="Css world!"
              exerciseInstructions="<div>Follow these instructions</div>"
            />
          </div>
        </div>
      </div>
      <Toaster />
    </FrontendTrainingPageContext.Provider>
  )
}
