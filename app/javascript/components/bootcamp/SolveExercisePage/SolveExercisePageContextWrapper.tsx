import React from 'react'
import { createContext } from 'react'

import { EditorView } from '@codemirror/view'

export type ExerciseLocalStorageData = {
  code: string
  storedAt: string | Date | null
  wasFinishLessonModalShown?: boolean
  readonlyRanges?:
    | {
        from: number
        to: number
      }[]
    | undefined
}

export type SolveExercisePageContextValues = Pick<
  SolveExercisePageProps,
  'links' | 'solution' | 'exercise' | 'code'
> & {
  resetEditorToStub: () => void
  editorView: EditorView | null
  isSpotlightActive: boolean
  exerciseLocalStorageData: ExerciseLocalStorageData
  setExerciseLocalStorageData: (data: ExerciseLocalStorageData) => void
}

export const SolveExercisePageContext =
  createContext<SolveExercisePageContextValues>({
    links: {} as SolveExercisePageContextValues['links'],
    solution: {} as SolveExercisePageContextValues['solution'],
    exercise: {} as SolveExercisePageContextValues['exercise'],
    code: {} as SolveExercisePageContextValues['code'],
    resetEditorToStub: () => {},
    editorView: {} as EditorView | null,
    isSpotlightActive: false,
    exerciseLocalStorageData: {} as ExerciseLocalStorageData,
    setExerciseLocalStorageData: () => {},
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
