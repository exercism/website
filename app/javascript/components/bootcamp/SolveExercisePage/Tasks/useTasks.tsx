import { useState, useContext, useCallback, useRef, useEffect } from 'react'
import { SolveExercisePageContext } from '../SolveExercisePageContextWrapper'
import { type NextExercise, completeSolution } from './completeSolution'
import type { TaskStore } from '../store/taskStore/taskStore'
import useAnimationTimelineStore from '../store/animationTimelineStore'
import { launchConfetti } from './launchConfetti'

export function useTasks({
  areAllTasksCompleted,
  wasFinishLessonModalShown,
  setWasFinishLessonModalShown,
}: Pick<
  TaskStore,
  | 'areAllTasksCompleted'
  | 'wasFinishLessonModalShown'
  | 'setWasFinishLessonModalShown'
>) {
  const [isFinishModalOpen, setIsFinishModalOpen] = useState(false)
  const [nextExerciseData, setNextExerciseData] = useState<NextExercise | null>(
    null
  )
  const [modalView, setModalView] = useState<'initial' | 'completedExercise'>(
    'initial'
  )
  const {
    links: { completeSolution: completeSolutionLink },
  } = useContext(SolveExercisePageContext)
  const { isTimelineComplete } = useAnimationTimelineStore()

  // Setup stage means stores are being set up - so we are in the initialising state in the lifecycle of the app
  // see useSetupStores.ts
  // here we care about areAllTasksCompleted
  // so we check if that is undefined - hasn't been set yet, or boolean - has been set
  const isSetupStage = useRef(true)

  useEffect(() => {
    // Don't show FinishLessonModal on page-revisit
    if (isSetupStage.current && areAllTasksCompleted !== undefined) {
      console.log('setup stage', areAllTasksCompleted)
      isSetupStage.current = false
    } else {
      if (
        areAllTasksCompleted &&
        isTimelineComplete &&
        !wasFinishLessonModalShown
      ) {
        console.log('being ehre')
        setIsFinishModalOpen(true)
        launchConfetti()
        setWasFinishLessonModalShown(true)
      }
    }
  }, [areAllTasksCompleted, wasFinishLessonModalShown, isTimelineComplete])

  const handleCompleteSolution = useCallback(async () => {
    try {
      const completedData = await completeSolution(completeSolutionLink)
      setNextExerciseData(completedData.next_exercise)
      if (!isFinishModalOpen) {
        setIsFinishModalOpen(true)
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
  }
}
