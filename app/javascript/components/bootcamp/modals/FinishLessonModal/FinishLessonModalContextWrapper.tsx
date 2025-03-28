import React from 'react'

import type { NextExercise } from '@/components/bootcamp/JikiscriptExercisePage/Tasks/completeSolution'
import { createContext } from 'react'
import { FinishLessonModalView } from '../../JikiscriptExercisePage/Tasks/useTasks'

type FinishLessonModalContextValues = {
  isFinishLessonModalOpen: boolean
  setIsFinishLessonModalOpen: (value: boolean) => void
  isCompletedBonusTasksModalOpen: boolean
  setIsCompletedBonusTasksModalOpen: (value: boolean) => void
  handleCompleteSolution: () => void
  nextExerciseData: NextExercise | null
  nextLevelIdx: number | null
  completedLevelIdx: number | null
  modalView: FinishLessonModalView
}

export const FinishLessonModalContext =
  createContext<FinishLessonModalContextValues>(
    {} as FinishLessonModalContextValues
  )

export function FinishLessonModalContextWrapper({
  children,
  value,
}: {
  children: React.ReactNode
  value: FinishLessonModalContextValues
}) {
  return (
    <FinishLessonModalContext.Provider value={value}>
      {children}
    </FinishLessonModalContext.Provider>
  )
}
