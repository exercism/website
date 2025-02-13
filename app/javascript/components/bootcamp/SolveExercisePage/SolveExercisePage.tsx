import React, { useMemo } from 'react'

import { useEditorHandler } from './CodeMirror/useEditorHandler'
import { Instructions } from './Instructions/Instructions'
import { useSetupStores } from './hooks/useSetupStores'
import { ControlButtons } from './ControlButtons/ControlButtons'
import { CodeMirror } from './CodeMirror/CodeMirror'
import ErrorBoundary from '../common/ErrorBoundary/ErrorBoundary'
import { Resizer, useResizablePanels } from './hooks/useResize'
import SolveExercisePageContextWrapper, {
  ExerciseLocalStorageData,
} from './SolveExercisePageContextWrapper'
import { Header } from './Header/Header'
import { useLocalStorage } from '@uidotdev/usehooks'
import { ResultsPanel } from './ResultsPanel'
import useTestStore from './store/testStore'
import useTaskStore from './store/taskStore/taskStore'

export default function SolveExercisePage({
  exercise,
  code,
  links,
  solution,
}: SolveExercisePageProps): JSX.Element {
  const [oldEditorLocalStorageValue] = useLocalStorage(
    'bootcamp-editor-value-' + exercise.config.title,
    {
      code: code.code,
      storedAt: code.storedAt,
      readonlyRanges: code.readonlyRanges,
      wasFinishLessonModalShown: false,
    }
  )

  const [exerciseLocalStorageData, setExerciseLocalStorageData] =
    useLocalStorage<{
      code: string
      storedAt: string | Date | null
      readonlyRanges?: { from: number; to: number }[]
    }>(
      'bootcamp-exercise-' + exercise.id,
      migrateToLatestCodeStorageData(code, oldEditorLocalStorageValue)
    )

  const {
    handleEditorDidMount,
    handleRunCode,
    editorViewRef,
    resetEditorToStub,
  } = useEditorHandler({
    links,
    exercise,
    code,
    exerciseLocalStorageData,
    setExerciseLocalStorageData,
  })

  useSetupStores({ exercise, code, exerciseLocalStorageData })
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
    initialSize: 500,
    secondaryMinSize: 250,
    direction: 'vertical',
    localStorageId: 'solve-exercise-page-editor-height',
  })

  const { testSuiteResult } = useTestStore()
  const { wasFinishLessonModalShown } = useTaskStore()

  const isSpotlightActive = useMemo(() => {
    if (!testSuiteResult) return false
    if (wasFinishLessonModalShown) return false
    return testSuiteResult.status === 'pass'
  }, [wasFinishLessonModalShown, testSuiteResult?.status])

  return (
    <SolveExercisePageContextWrapper
      value={{
        links,
        solution,
        exercise,
        code,
        resetEditorToStub,
        editorView: editorViewRef.current,
        isSpotlightActive,
        exerciseLocalStorageData,
        setExerciseLocalStorageData,
      }}
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
              <ResultsPanel />
            </div>
          </div>
          <Resizer direction="vertical" handleMouseDown={handleMouseDown} />
          {/* RHS */}
          <div className="page-body-rhs" style={{ width: RHSWidth }}>
            <Instructions
              exerciseTitle={exercise.title}
              exerciseInstructions={exercise.introductionHtml}
            />
          </div>
        </div>
      </div>
    </SolveExercisePageContextWrapper>
  )
}

export function migrateToLatestCodeStorageData(
  code: Code,
  deprecatedStorage: ExerciseLocalStorageData
): ExerciseLocalStorageData {
  const deprecatedDataIsNewer =
    !!code.storedAt &&
    !!deprecatedStorage.storedAt &&
    deprecatedStorage.storedAt > code.storedAt
  const onlyDeprecatedExists = !code.storedAt && !!deprecatedStorage.storedAt

  if (deprecatedDataIsNewer || onlyDeprecatedExists) {
    return deprecatedStorage
  }

  return {
    code: code.code,
    readonlyRanges: code.readonlyRanges,
    storedAt: code.storedAt,
    wasFinishLessonModalShown: false,
  }
}
