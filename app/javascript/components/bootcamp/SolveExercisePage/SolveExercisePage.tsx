import React from 'react'

import { useEditorHandler } from './CodeMirror/useEditorHandler'
import { InspectedTestResultView } from './TestResultsView/InspectedTestResultView'
import { Instructions } from './Instructions/Instructions'
import { useSetupStores } from './hooks/useSetupStores'
import { ControlButtons } from './ControlButtons/ControlButtons'
import { CodeMirror } from './CodeMirror/CodeMirror'
import ErrorBoundary from '../common/ErrorBoundary/ErrorBoundary'
import { Resizer, useResizablePanels } from './hooks/useResize'
import { TaskPreview } from './TaskPreview/TaskPreview'
import SolveExercisePageContextWrapper from './SolveExercisePageContextWrapper'
import { PreviousTestResultView } from './PreviousTestResultsView/PreviousTestResultsView'
import { Header } from './Header/Header'
import { useLocalStorage } from '@uidotdev/usehooks'

export default function SolveExercisePage({
  exercise,
  code,
  links,
  solution,
}: SolveExercisePageProps): JSX.Element {
  // this returns handleRunCode which is onRunCode but with studentCode passed in as an argument
  const {
    handleEditorDidMount,
    handleRunCode,
    editorViewRef,
    resetEditorToStub,
  } = useEditorHandler({
    links,
    config: exercise.config,
    code,
  })

  useSetupStores({ exercise, code })
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
    primarySize: TopHeight,
    secondarySize: BottomHeight,
    handleMouseDown: handleHeightChangeMouseDown,
  } = useResizablePanels({
    initialSize: 800,
    secondaryMinSize: 200,
    direction: 'vertical',
    localStorageId: 'solve-exercise-page-editor-height',
  })

  const [_, setEditorLocalStorageValue] = useLocalStorage(
    'bootcamp-editor-value-' + exercise.config.title,
    { code: code.code, storedAt: code.storedAt }
  )

  return (
    <SolveExercisePageContextWrapper
      value={{ links, solution, exercise, code, resetEditorToStub }}
    >
      <div id="bootcamp-solve-exercise-page">
        <Header />
        <div className="page-body">
          <div style={{ width: LHSWidth }} className="page-body-lhs">
            <ErrorBoundary>
              <CodeMirror
                style={{ height: `${TopHeight}px` }}
                ref={editorViewRef}
                editorDidMount={handleEditorDidMount}
                handleRunCode={handleRunCode}
                setEditorLocalStorageValue={setEditorLocalStorageValue}
              />
            </ErrorBoundary>

            <Resizer
              direction="horizontal"
              handleMouseDown={handleHeightChangeMouseDown}
            />

            <div
              className="page-body-lhs-bottom"
              style={{ height: BottomHeight }}
            >
              <ControlButtons handleRunCode={handleRunCode} />
              <InspectedTestResultView />
              <TaskPreview />
              <PreviousTestResultView exercise={exercise} />
            </div>
          </div>
          <Resizer direction="vertical" handleMouseDown={handleMouseDown} />
          {/* RHS */}
          <div className="page-body-rhs" style={{ width: RHSWidth }}>
            <Instructions exerciseInstructions={exercise.introductionHtml} />
            {/* <Tasks /> */}
          </div>
        </div>
      </div>
    </SolveExercisePageContextWrapper>
  )
}
