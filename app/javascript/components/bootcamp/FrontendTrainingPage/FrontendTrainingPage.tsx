import React, { useRef } from 'react'
import { Resizer } from '../SolveExercisePage/hooks/useResize'
import { CodeMirror } from '../SolveExercisePage/CodeMirror/CodeMirror'
import { Instructions } from './Instructions'
import { css } from '@codemirror/lang-css'
import { basicLight } from 'cm6-theme-basic-light'
import { Prec } from '@codemirror/state'
import { ActualOutput } from './ActualOutput'
import { ExpectedOutput } from './ExpectedOutput'
import { updateIFrame } from './utils/updateIFrame'
import { Toaster } from 'react-hot-toast'
import { Header } from './Header'
import { FrontendTrainingPageContext } from './FrontendTrainingPageContext'
import { interactionExtension } from './extensions/interaction'
import { useInitResizablePanels } from './hooks/useInitResizablePanels'
import { useSetupEditors } from './hooks/useSetupEditors'
import { useSetupIFrames } from './hooks/useSetupIFrames'
import { LHS } from './LHS/LHS'

export default function FrontendTrainingPage() {
  const actualOutputRef = useRef<HTMLDivElement>(null)
  const {
    actualIFrameRef,
    expectedIFrameRef,
    expectedReferenceIFrameRef,
    handleCompare,
  } = useSetupIFrames()

  const { LHSWidth, RHSWidth, handleWidthChangeMouseDown } =
    useInitResizablePanels()

  const {
    htmlEditorViewRef,
    cssEditorViewRef,
    handleCssEditorDidMount,
    handleHtmlEditorDidMount,
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
        handleCssEditorDidMount,
        handleHtmlEditorDidMount,
        LHSWidth,
        RHSWidth,
      }}
    >
      <div id="bootcamp-front-end-training-page">
        <Header onCompare={handleCompare} />
        <div className="page-body">
          <LHS />
        </div>

        {/* <div className="flex flex-col gap-12">
          <div ref={actualOutputRef} />
          <ActualOutput />
          <ExpectedOutput />
        </div>
        <Resizer
          direction="vertical"
          handleMouseDown={handleWidthChangeMouseDown}
        />
        <div className="page-body-rhs" style={{ width: RHSWidth }}>
          <Instructions
            exerciseTitle="Css world!"
            exerciseInstructions="<div>Follow these instructions</div>"
          />
        </div> */}
      </div>
      <Toaster />
    </FrontendTrainingPageContext.Provider>
  )
}
