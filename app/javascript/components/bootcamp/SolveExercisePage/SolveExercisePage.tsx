import React from 'react'

import { useEditorHandler } from './CodeMirror/useEditorHandler'
import { InspectedTestResultView } from './TestResultsView/InspectedTestResultView'
import { Tasks } from './Tasks/Tasks'
import { Instructions } from './Instructions/Instructions'
import { useSetupStores } from './hooks/useSetupStores'
import { ControlButtons } from './ControlButtons/ControlButtons'
import { CodeMirror } from './CodeMirror/CodeMirror'
import { ErrorBoundary } from '@/components/ErrorBoundary'
import { Resizer, useResizablePanels } from './hooks/useResize'
import { TaskPreview } from './TaskPreview/TaskPreview'
import SolveExercisePageContextWrapper from './SolveExercisePageContextWrapper'
import { PreviousTestResultView } from './PreviousTestResultsView/PreviousTestResultsView'

export default function SolveExercisePage({
  exercise,
  code,
  links,
  solution,
}: SolveExercisePageProps): JSX.Element {
  // this returns handleRunCode which is onRunCode but with studentCode passed in as an argument
  const { handleEditorDidMount, handleRunCode, editorViewRef } =
    useEditorHandler({
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

  return (
    <SolveExercisePageContextWrapper value={{ links, solution, exercise }}>
      <div id="bootcamp-solve-exercise-page" className="flex w-full h-screen">
        {/* LHS */}
        <div style={{ width: `${LHSWidth}px` }} className="flex flex-col">
          <ErrorBoundary>
            <CodeMirror
              style={{ height: `${TopHeight}px` }}
              ref={editorViewRef}
              editorDidMount={handleEditorDidMount}
              handleRunCode={handleRunCode}
            />
          </ErrorBoundary>
          <Resizer
            direction="horizontal"
            handleMouseDown={handleHeightChangeMouseDown}
          />

          <div className="flex flex-col" style={{ height: BottomHeight }}>
            <ControlButtons handleRunCode={handleRunCode} />
            <InspectedTestResultView />
            <TaskPreview exercise={exercise} />
            <PreviousTestResultView exercise={exercise} />
          </div>
        </div>
        <Resizer direction="vertical" handleMouseDown={handleMouseDown} />
        {/* RHS */}
        <div className="h-full" style={{ width: RHSWidth }}>
          <Instructions exerciseInstructions={exercise.introductionHtml} />
          <Tasks />
        </div>
      </div>
    </SolveExercisePageContextWrapper>
  )
}
