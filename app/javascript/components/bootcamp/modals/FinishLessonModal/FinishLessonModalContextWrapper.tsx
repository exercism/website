import React from 'react'

import type { NextExercise } from '@/components/bootcamp/SolveExercisePage/Tasks/completeSolution'
import { createContext } from 'react'
import { FinishLessonModalView } from '../../SolveExercisePage/Tasks/useTasks'

type FinishLessonModalContextValues = {
  isOpen: boolean
  setIsOpen: (value: boolean) => void
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
