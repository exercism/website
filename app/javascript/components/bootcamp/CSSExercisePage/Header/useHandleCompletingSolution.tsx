import { useState, useCallback } from 'react'
import {
  NextExercise,
  completeSolution,
} from '../../JikiscriptExercisePage/Tasks/completeSolution'

export type FinishLessonModalView =
  | 'initial'
  | 'completedExercise'
  | 'completedLevel'
  | 'completedAllLevels'
  | 'completedEverything'

export function useHandleCompletingSolution({
  isFinishModalOpen,
  setIsFinishModalOpen,
  completeSolutionLink,
}: {
  isFinishModalOpen: boolean
  setIsFinishModalOpen: (value: boolean) => void
  completeSolutionLink: string
}) {
  const [nextExerciseData, setNextExerciseData] = useState<NextExercise | null>(
    null
  )

  const [nextLevelIdx, setNextLevelIdx] = useState<number | null>(null)
  const [completedLevelIdx, setCompletedLevelIdx] = useState<number | null>(
    null
  )
  const [modalView, setModalView] = useState<FinishLessonModalView>('initial')

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
      } else {
        setModalView('completedExercise')
      }
    } catch (e) {
      console.error('Error completing solution: ', e)
    }
  }, [completeSolutionLink, nextExerciseData, isFinishModalOpen])

  return {
    modalView,
    handleCompleteSolution,
    nextExerciseData,
    nextLevelIdx,
    completedLevelIdx,
  }
}
