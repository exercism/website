import {
  useState,
  useContext,
  useCallback,
  useRef,
  useEffect,
  useMemo,
} from 'react'
import { JikiscriptExercisePageContext } from '../JikiscriptExercisePageContextWrapper'
import { type NextExercise, completeSolution } from './completeSolution'
import useAnimationTimelineStore from '../store/animationTimelineStore'
import { launchConfetti } from './launchConfetti'
import useTestStore from '../store/testStore'
import useTaskStore from '../store/taskStore/taskStore'

export type FinishLessonModalView =
  | 'initial'
  | 'completedExercise'
  | 'completedLevel'
  | 'completedAllLevels'
  | 'completedEverything'

export function useTasks() {
  const [isFinishModalOpen, setIsFinishModalOpen] = useState(false)
  const [isCompletedBonusTasksModalOpen, setIsCompletedBonusTasksModalOpen] =
    useState(false)

  const [nextExerciseData, setNextExerciseData] = useState<NextExercise | null>(
    null
  )

  const [nextLevelIdx, setNextLevelIdx] = useState<number | null>(null)
  const [completedLevelIdx, setCompletedLevelIdx] = useState<number | null>(
    null
  )
  const [modalView, setModalView] = useState<FinishLessonModalView>('initial')

  const {
    areAllTasksCompleted,
    wasFinishLessonModalShown,
    setWasFinishLessonModalShown,
    wasCompletedBonusTasksModalShown,
    setWasCompletedBonusTasksModalShown,
  } = useTaskStore()
  const {
    solution,
    exercise,
    links: { completeSolution: completeSolutionLink },
  } = useContext(JikiscriptExercisePageContext)
  const { isTimelineComplete } = useAnimationTimelineStore()
  const { inspectedTestResult, bonusTestSuiteResult, testSuiteResult } =
    useTestStore()

  // Setup stage means stores are being set up - so we are in the initialising state in the lifecycle of the app
  // see useSetupStores.ts
  // here we care about areAllTasksCompleted
  // so we check if that is undefined - hasn't been set yet, or boolean - has been set
  const isSetupStage = useRef(true)
  const hasRuntimeErrors = useMemo(() => {
    if (inspectedTestResult) {
      return inspectedTestResult.frames.some((f) => f.status === 'ERROR')
    }
  }, [inspectedTestResult])

  useEffect(() => {
    // Don't show FinishLessonModal on page-revisit
    const allBonusTestsPassed =
      bonusTestSuiteResult &&
      bonusTestSuiteResult.tests.length > 0 &&
      bonusTestSuiteResult.status === 'pass' &&
      testSuiteResult &&
      testSuiteResult.tests.length > 0 &&
      testSuiteResult.status === 'pass'

    if (isSetupStage.current && areAllTasksCompleted !== undefined) {
      isSetupStage.current = false
    } else {
      const shouldShowModal = areAllTasksCompleted && !wasFinishLessonModalShown
      const hasTimeline =
        exercise.language === 'jikiscript' &&
        !!inspectedTestResult?.animationTimeline
      // if we don't have a timeline, we don't need to wait for it to be complete
      const isTimelineReady = hasTimeline ? isTimelineComplete : true

      if (shouldShowModal && isTimelineReady && !hasRuntimeErrors) {
        setIsFinishModalOpen(true)
        launchConfetti()
        setWasFinishLessonModalShown(true)

        // if student completes bonus tests and normal tests in one go, we mark bonus completion modal as shown
        if (bonusTestSuiteResult?.status === 'pass') {
          setWasCompletedBonusTasksModalShown(true)
        }
      }
      if (
        wasFinishLessonModalShown &&
        isTimelineReady &&
        !wasCompletedBonusTasksModalShown &&
        allBonusTestsPassed
      ) {
        setIsCompletedBonusTasksModalOpen(true)
        launchConfetti()
        setWasCompletedBonusTasksModalShown(true)
      }
    }
  }, [
    areAllTasksCompleted,
    wasFinishLessonModalShown,
    wasCompletedBonusTasksModalShown,
    isTimelineComplete,
    inspectedTestResult,
    solution.status,
    bonusTestSuiteResult,
  ])

  const handleCompleteSolution = useCallback(async () => {
    try {
      const completedData = await completeSolution(completeSolutionLink)
      setNextExerciseData(completedData.next_exercise)
      setNextLevelIdx(completedData.next_level_idx)
      if (!isFinishModalOpen) {
        setIsFinishModalOpen(true)
      }

      // since completed bonus tasks modal is not part of the finish lesson modal views, we must close it if it is open
      if (isCompletedBonusTasksModalOpen) {
        setIsCompletedBonusTasksModalOpen(false)
      }

      if (completedData.completed_level_idx) {
        setModalView('completedLevel')
        setCompletedLevelIdx(completedData.completed_level_idx)
      } else {
        setModalView('completedExercise')
      }
    } catch (e) {
      console.error('Error completing solution: ', e)
    }
  }, [
    completeSolutionLink,
    nextExerciseData,
    isFinishModalOpen,
    isCompletedBonusTasksModalOpen,
  ])

  return {
    modalView,
    isFinishModalOpen,
    handleCompleteSolution,
    setIsFinishModalOpen,
    nextExerciseData,
    nextLevelIdx,
    completedLevelIdx,
    hasRuntimeErrors,
    isCompletedBonusTasksModalOpen,
    setIsCompletedBonusTasksModalOpen,
  }
}
