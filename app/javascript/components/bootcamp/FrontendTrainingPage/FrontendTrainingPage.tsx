import React, { useRef } from 'react'
import {
  Resizer,
  useResizablePanels,
} from '../SolveExercisePage/hooks/useResize'
import { CodeMirror } from '../SolveExercisePage/CodeMirror/CodeMirror'
import { useHtmlEditorHandler } from './useHtmlEditorHandler'
import { Instructions } from '../SolveExercisePage/Instructions/Instructions'
import { html } from '@codemirror/lang-html'
import { basicLight } from 'cm6-theme-basic-light'
import { Prec } from '@codemirror/state'
import { ActualOutput } from './ActualOutput'
import { ExpectedOutput } from './ExpectedOutput'
import { updateIFrame } from './updateIFrame'

export default function FrontendTrainingPage() {
  const {
    primarySize: TopHeight,
    secondarySize: BottomHeight,
    handleMouseDown: handleHeightChangeMouseDown,
  } = useResizablePanels({
    initialSize: 500,
    secondaryMinSize: 250,
    direction: 'vertical',
    localStorageId: 'frontend-training-page-lhs-height',
  })

  const actualIFrameRef = useRef<HTMLIFrameElement>(null)
  const expectedIFrameRef = useRef<HTMLIFrameElement>(null)

  const {
    primarySize: LHSWidth,
    secondarySize: RHSWidth,
    handleMouseDown,
  } = useResizablePanels({
    initialSize: 800,
    direction: 'horizontal',
    localStorageId: 'solve-exercise-page-lhs',
  })

  const {
    editorViewRef: htmlEditorViewRef,
    handleEditorDidMount: handleHtmlEditorDidMount,
  } = useHtmlEditorHandler()
  const {
    editorViewRef: cssEditorViewRef,
    handleEditorDidMount: handleCssEditorDidMount,
  } = useHtmlEditorHandler()

  return (
    <div id="bootcamp-custom-function-editor-page">
      <div className="page-body">
        <div className="page-body-lhs" style={{ width: LHSWidth }}>
          <CodeMirror
            style={{ height: `${TopHeight}px` }}
            editorDidMount={handleHtmlEditorDidMount}
            extensions={[Prec.highest([html(), basicLight])]}
            onEditorChangeCallback={(view) => {
              const html = view.state.doc.toString()
              const css = cssEditorViewRef.current?.state.doc.toString() || ''
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
              const html = htmlEditorViewRef.current?.state.doc.toString() || ''
              updateIFrame(actualIFrameRef, html, css)
            }}
            handleRunCode={() => {}}
            ref={cssEditorViewRef}
          />
        </div>

        <div className="flex flex-col gap-12">
          <button
            onClick={async () => {
              // const result = await compareIframes(actualIFrameRef, expectedIFrameRef)
              // console.log('comparing', result)
            }}
            className="btn-xxs btn-primary"
          >
            Compare
          </button>
          <ActualOutput ref={actualIFrameRef} />
          <ExpectedOutput ref={expectedIFrameRef} />
        </div>
        <Resizer direction="vertical" handleMouseDown={handleMouseDown} />
        <div className="page-body-rhs" style={{ width: RHSWidth }}>
          <Instructions
            exerciseTitle="Css world!"
            exerciseInstructions="<div>Follow these instructions</div>"
          />
        </div>
      </div>
    </div>
  )
}
