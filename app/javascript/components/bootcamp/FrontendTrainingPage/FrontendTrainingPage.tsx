import React, { useCallback, useState } from 'react'
import { Resizer } from '../SolveExercisePage/hooks/useResize'
import { CodeMirror } from '../SolveExercisePage/CodeMirror/CodeMirror'
import { Instructions } from './Instructions'
import { html } from '@codemirror/lang-html'
import { basicLight } from 'cm6-theme-basic-light'
import { Prec } from '@codemirror/state'
import { ActualOutput } from './ActualOutput'
import { ExpectedOutput } from './ExpectedOutput'
import { updateIFrame } from './utils/updateIFrame'
import { Toaster } from 'react-hot-toast'
import { Header } from './Header'
import { useInitResizablePanels } from './useInitResizablePanels'
import { useSetupEditors } from './useSetupEditors'
import { useSetupIFrames } from './useSetupIFrames'
import { FrontendTrainingPageContext } from './FrontendTrainingPageContext'
import { interpret } from '@/css-interpreter/interpreter'
import Scrubber from '../SolveExercisePage/Scrubber/Scrubber'
import { Frame } from '@/css-interpreter/frames'
import { buildAnimationTimeline } from '../SolveExercisePage/test-runner/generateAndRunTestSuite/execTest'
import { showError } from '../SolveExercisePage/utils/showError'
import useEditorStore from '../SolveExercisePage/store/editorStore'
import SolveExercisePageContextWrapper from '../SolveExercisePage/SolveExercisePageContextWrapper'

export default function FrontendTrainingPage() {
  const {
    actualIFrameRef,
    expectedIFrameRef,
    expectedReferenceIFrameRef,
    handleCompare,
  } = useSetupIFrames()

  const {
    BottomHeight,
    LHSWidth,
    RHSWidth,
    TopHeight,
    handleHeightChangeMouseDown,
    handleWidthChangeMouseDown,
  } = useInitResizablePanels()

  const {
    htmlEditorViewRef,
    cssEditorViewRef,
    handleCssEditorDidMount,
    handleHtmlEditorDidMount,
    setEditorCodeLocalStorage,
  } = useSetupEditors()

  const {
    setUnderlineRange,
    setHighlightedLine,
    setHighlightedLineColor,
    setInformationWidgetData,
    setShouldShowInformationWidget,
    setHasCodeBeenEdited,
  } = useEditorStore()

  const [frames, setFrames] = useState<Frame[] | undefined>(undefined)
  const [cssAnimationTimeline, setCssAnimationTimeline] = useState()
  const interpreterCssCode = useCallback(() => {
    const cssCode = cssEditorViewRef.current?.state.doc.toString() || ''
    const interpretation = interpret(cssCode)
    if (interpretation.error) {
      showError({
        error: interpretation.error,
        editorView: cssEditorViewRef.current,
        setHighlightedLine,
        setHighlightedLineColor,
        setInformationWidgetData,
        setShouldShowInformationWidget,
        setUnderlineRange,
      })
    }

    setHasCodeBeenEdited(false)
    const { frames } = interpretation
    if (frames && frames.length > 0) {
      setFrames(frames)
      const animationTimeline = buildAnimationTimeline(undefined, frames)
      console.log(animationTimeline)
      setCssAnimationTimeline(animationTimeline)
    }

    console.log(interpretation)
  }, [])

  return (
    <SolveExercisePageContextWrapper
      value={{
        editorView: cssEditorViewRef.current,
        isSpotlightActive: false,
        links: {} as SolveExercisePageProps['links'],
      }}
    >
      <FrontendTrainingPageContext.Provider
        value={{
          actualIFrameRef,
          expectedIFrameRef,
          expectedReferenceIFrameRef,
        }}
      >
        <div id="bootcamp-front-end-training-page">
          <Header onCompare={handleCompare} />
          <div className="page-body">
            <div className="page-body-lhs" style={{ width: LHSWidth }}>
              <CodeMirror
                style={{ height: `${TopHeight}px` }}
                editorDidMount={handleHtmlEditorDidMount}
                extensions={[Prec.highest([html(), basicLight])]}
                onEditorChangeCallback={(view) => {
                  const html = view.state.doc.toString()
                  const css =
                    cssEditorViewRef.current?.state.doc.toString() || ''
                  setEditorCodeLocalStorage({
                    htmlEditorContent: html,
                    cssEditorContent: css,
                  })
                  updateIFrame(actualIFrameRef, html, css)
                }}
                handleRunCode={() => {}}
                ref={htmlEditorViewRef}
              />
              <Resizer
                direction="horizontal"
                handleMouseDown={handleHeightChangeMouseDown}
              />
              <CodeMirror
                style={{ height: `${BottomHeight - 100}px` }}
                editorDidMount={handleCssEditorDidMount}
                onEditorChangeCallback={(view) => {
                  const css = view.state.doc.toString()
                  const html =
                    htmlEditorViewRef.current?.state.doc.toString() || ''
                  updateIFrame(actualIFrameRef, html, css)
                  setEditorCodeLocalStorage({
                    htmlEditorContent: html,
                    cssEditorContent: css,
                  })
                }}
                handleRunCode={() => {}}
                ref={cssEditorViewRef}
              />

              <div className="page-body-lhs-bottom">
                <button
                  onClick={interpreterCssCode}
                  className="btn-primary btn-s grow shrink-0 w-fit"
                >
                  Interpret CSS
                </button>
                {cssAnimationTimeline && frames && (
                  <Scrubber
                    animationTimeline={cssAnimationTimeline}
                    frames={frames}
                  />
                )}
              </div>
            </div>

            <div className="flex flex-col gap-12">
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
            </div>
          </div>
          <Toaster />
        </div>
      </FrontendTrainingPageContext.Provider>
    </SolveExercisePageContextWrapper>
  )
}
