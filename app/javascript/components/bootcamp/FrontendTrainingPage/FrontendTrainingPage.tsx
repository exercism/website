import React from 'react'
import {
  Resizer,
  useResizablePanels,
} from '../SolveExercisePage/hooks/useResize'
import { CodeMirror } from '../SolveExercisePage/CodeMirror/CodeMirror'
import { useHtmlEditorHandler } from './useHtmlEditorHandler'
import { Instructions } from '../SolveExercisePage/Instructions/Instructions'

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
            handleRunCode={() => {}}
            ref={cssEditorViewRef}
          />
        </div>

        <div className="flex flex-col gap-12">
          <div className="p-24">
            <h3 className="mb-12 font-mono font-semibold">Expected: </h3>
            <div className="bg-gray-400 rounded-12 w-[350px] h-[350px]"></div>
          </div>

          <div className="p-24">
            <h3 className="mb-12 font-mono font-semibold">Actual: </h3>
            <div className="bg-gray-400 rounded-12 w-[350px] h-[350px]"></div>
          </div>
        </div>
        <Resizer direction="vertical" handleMouseDown={handleMouseDown} />
        <div className="page-body-rhs">
          <Instructions
            exerciseTitle="Css world!"
            exerciseInstructions="<div>Follow these instructions</div>"
          />
        </div>
      </div>
    </div>
  )
}
