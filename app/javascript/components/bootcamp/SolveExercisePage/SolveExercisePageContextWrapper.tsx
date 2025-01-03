import React from 'react'

import { createContext } from 'react'

type SolveExercisePageContextValues = Pick<
  SolveExercisePageProps,
  'links' | 'solution' | 'exercise'
>

export const SolveExercisePageContext =
  createContext<SolveExercisePageContextValues>({
    links: {} as SolveExercisePageContextValues['links'],
    solution: {} as SolveExercisePageContextValues['solution'],
    exercise: {} as SolveExercisePageContextValues['exercise'],
  })

export default function SolveExercisePageContextWrapper({
  children,
  value,
}: {
  children: React.ReactNode
  value: SolveExercisePageContextValues
}) {
  return (
    <SolveExercisePageContext.Provider value={value}>
      {children}
    </SolveExercisePageContext.Provider>
  )
}
