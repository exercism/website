import type { NextExercise } from '@/components/bootcamp/SolveExercisePage/Tasks/completeSolution'
import { createContext } from 'react'

type FinishLessonModalContextValues = {
  isOpen: boolean
  setIsOpen: (value: boolean) => void
  handleCompleteSolution: () => void
  nextExerciseData: NextExercise | null
  modalView: 'initial' | 'completedExercise'
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
