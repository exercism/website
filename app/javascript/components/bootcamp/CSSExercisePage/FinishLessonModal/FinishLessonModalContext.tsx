import type { NextExercise } from '@/components/bootcamp/JikiscriptExercisePage/Tasks/completeSolution'
import { createContext } from 'react'
import { FinishLessonModalView } from '../../JikiscriptExercisePage/Tasks/useTasks'

type FinishLessonModalContextValues = {
  isFinishLessonModalOpen: boolean
  setIsFinishLessonModalOpen: (value: boolean) => void
  handleCompleteSolution: () => void
  nextExerciseData: NextExercise | null
  nextLevelIdx: number | null
  completedLevelIdx: number | null
  modalView: FinishLessonModalView
  links: { dashboardIndex: string; bootcampLevelUrl: string }
}

export const FinishLessonModalContext =
  createContext<FinishLessonModalContextValues>(
    {} as FinishLessonModalContextValues
  )
