import {
  useState,
  useContext,
  useCallback,
  useRef,
  useEffect,
  useMemo,
} from 'react'
import { SolveExercisePageContext } from '../SolveExercisePageContextWrapper'
import { type NextExercise, completeSolution } from './completeSolution'
import useAnimationTimelineStore from '../store/animationTimelineStore'
import { launchConfetti } from './launchConfetti'
import useTestStore from '../store/testStore'
import { useLocalStorage } from '@uidotdev/usehooks'
import useTaskStore from '../store/taskStore/taskStore'

export type FinishLessonModalView =
  | 'initial'
  | 'completedExercise'
  | 'completedLevel'

export function useTasks() {
  const [isFinishModalOpen, setIsFinishModalOpen] = useState(false)
  const [nextExerciseData, setNextExerciseData] = useState<NextExercise | null>(
    null
  )
  const [modalsShown, setModalsShown] = useLocalStorage<string[]>(
    'finish-modals-shown',
    []
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
  } = useTaskStore()
  const {
    solution,
    links: { completeSolution: completeSolutionLink },
    exercise: { title: exerciseTitle },
  } = useContext(SolveExercisePageContext)
  const { isTimelineComplete } = useAnimationTimelineStore()
  const { inspectedTestResult } = useTestStore()

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
    if (isSetupStage.current && areAllTasksCompleted !== undefined) {
      // if the solution is marked as `completed` on mount, the modal was once shown in the past
      if (
        solution.status === 'completed' ||
        modalsShown.includes(exerciseTitle)
      ) {
        setWasFinishLessonModalShown(true)
      }
      isSetupStage.current = false
    } else {
      const shouldShowModal = areAllTasksCompleted && !wasFinishLessonModalShown
      const hasTimeline = !!inspectedTestResult?.animationTimeline
      // if we don't have a timeline, we don't need to wait for it to be complete
      const isTimelineReady = hasTimeline ? isTimelineComplete : true

      if (shouldShowModal && isTimelineReady && !hasRuntimeErrors) {
        setIsFinishModalOpen(true)
        launchConfetti()
        setWasFinishLessonModalShown(true)
        setModalsShown([...modalsShown, exerciseTitle])
      }
    }
  }, [
    areAllTasksCompleted,
    wasFinishLessonModalShown,
    isTimelineComplete,
    inspectedTestResult,
    solution.status,
  ])

  const handleCompleteSolution = useCallback(async () => {
    try {
      const completedData = await completeSolution(completeSolutionLink)
      setNextExerciseData(completedData.next_exercise)
      setNextLevelIdx(completedData.next_level_idx)
      if (!isFinishModalOpen) {
        setIsFinishModalOpen(true)
      }

      if (completedData.completed_level_idx) {
        setModalView('completedLevel')
        setCompletedLevelIdx(completedData.completed_level_idx)
        return
      }
      setModalView('completedExercise')
    } catch (e) {
      console.error('Error completing solution: ', e)
    }
  }, [completeSolutionLink, nextExerciseData, isFinishModalOpen])

  return {
    modalView,
    isFinishModalOpen,
    handleCompleteSolution,
    setIsFinishModalOpen,
    nextExerciseData,
    nextLevelIdx,
    completedLevelIdx,
    hasRuntimeErrors,
  }
}
