import React from 'react'
import { Resizer } from '../SolveExercisePage/hooks/useResize'
import { CodeMirror } from '../SolveExercisePage/CodeMirror/CodeMirror'
import { Instructions } from '../SolveExercisePage/Instructions/Instructions'
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

  return (
    <FrontendTrainingPageContext.Provider
      value={{
        actualIFrameRef,
        expectedIFrameRef,
        expectedReferenceIFrameRef,
      }}
    >
      <div id="bootcamp-custom-function-editor-page">
        <Header onCompare={handleCompare} />
        <div className="page-body">
          <div className="page-body-lhs" style={{ width: LHSWidth }}>
            <CodeMirror
              style={{ height: `${TopHeight}px` }}
              editorDidMount={handleHtmlEditorDidMount}
              extensions={[Prec.highest([html(), basicLight])]}
              onEditorChangeCallback={(view) => {
                const html = view.state.doc.toString()
                const css = cssEditorViewRef.current?.state.doc.toString() || ''
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
              style={{ height: `${BottomHeight}px` }}
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
  )
}
