import React, { useMemo } from 'react'

import { useEditorHandler } from './CodeMirror/useEditorHandler'
import { Instructions } from './RHS/Instructions/Instructions'
import { useSetupStores } from './hooks/useSetupStores'
import { ControlButtons } from './ControlButtons/ControlButtons'
import { CodeMirror } from './CodeMirror/CodeMirror'
import ErrorBoundary from '../common/ErrorBoundary/ErrorBoundary'
import { Resizer, useResizablePanels } from './hooks/useResize'
import { Header } from './Header/Header'
import { useLocalStorage } from '@uidotdev/usehooks'
import { ResultsPanel } from './ResultsPanel'
import useTestStore from './store/testStore'
import useTaskStore from './store/taskStore/taskStore'
import { generateUnfoldableFunctioNames as generateUnfoldableFunctionNames } from './store/taskStore/generateUnfoldableFunctionNames'
import exerciseMap from './utils/exerciseMap'
import { Project } from './utils/exerciseMap'
import JikiscriptExercisePageContextWrapper, {
  ExerciseLocalStorageData,
} from './JikiscriptExercisePageContextWrapper'
import { Logger } from './RHS/Logger/Logger'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { RHS } from './RHS/RHS'

export default function JikiscriptExercisePage({
  exercise,
  code,
  links,
  solution,
  customFunctions,
}: JikiscriptExercisePageProps): JSX.Element {
  const { wasFinishLessonModalShown, wasCompletedBonusTasksModalShown } =
    useTaskStore()

  const [oldEditorLocalStorageValue] = useLocalStorage(
    'bootcamp-editor-value-' + exercise.config.title,
    {
      code: code.code,
      storedAt: code.storedAt,
      readonlyRanges: code.readonlyRanges,
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
    unfoldableFunctionNames: generateUnfoldableFunctionNames(),
  })

  useSetupStores({
    exercise,
    code,
    solution,
    customFunctions,
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
    primarySize: TopHeight,
    secondarySize: BottomHeight,
    handleMouseDown: handleHeightChangeMouseDown,
  } = useResizablePanels({
    initialSize: 500,
    secondaryMinSize: 250,
    direction: 'vertical',
    localStorageId: 'solve-exercise-page-editor-height',
  })

  const { testSuiteResult, bonusTestSuiteResult } = useTestStore()

  const project: Project | undefined = useMemo(
    () => exerciseMap.get(exercise.config.projectType),
    [exercise]
  )

  /* spotlight is active if 
   - testSuiteResult is passing and basic testResult modal wasn't shown before
   - bonus tests are unlocked, bonusTestSuiteResult is passing and bonus modal wasn't shown before 
  */
  const isSpotlightActive = useMemo(() => {
    if (!project?.hasView) return false

    const basicTestsArePassing = testSuiteResult?.status === 'pass'
    const bonusExists = !!bonusTestSuiteResult
    const bonusHasTests = bonusExists && bonusTestSuiteResult.tests.length > 0
    const bonusTestsArePassing =
      bonusHasTests && bonusTestSuiteResult?.status === 'pass'

    const isActiveForBasicTasks =
      basicTestsArePassing && !wasFinishLessonModalShown

    const isActiveForBonusTasks =
      basicTestsArePassing &&
      bonusTestsArePassing &&
      !wasCompletedBonusTasksModalShown

    return isActiveForBasicTasks || isActiveForBonusTasks
  }, [
    project,
    wasFinishLessonModalShown,
    testSuiteResult?.status,
    wasCompletedBonusTasksModalShown,
    bonusTestSuiteResult?.status,
  ])

  return (
    <JikiscriptExercisePageContextWrapper
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
          <RHS width={RHSWidth} />
        </div>
      </div>
    </JikiscriptExercisePageContextWrapper>
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
  }
}
