import React from 'react'
import { createContext } from 'react'

import { EditorView } from '@codemirror/view'

export type ExerciseLocalStorageData = {
  code: string
  storedAt: string | Date | null
  readonlyRanges?:
    | {
        from: number
        to: number
      }[]
    | undefined
}

export type JikiscriptExercisePageContextValues = Pick<
  JikiscriptExercisePageProps,
  'links' | 'solution' | 'exercise' | 'code'
> & {
  resetEditorToStub: () => void
  editorView: EditorView | null
  isSpotlightActive: boolean
  exerciseLocalStorageData: ExerciseLocalStorageData
  setExerciseLocalStorageData: (data: ExerciseLocalStorageData) => void
}

export const JikiscriptExercisePageContext =
  createContext<JikiscriptExercisePageContextValues>({
    links: {} as JikiscriptExercisePageContextValues['links'],
    solution: {} as JikiscriptExercisePageContextValues['solution'],
    exercise: {} as JikiscriptExercisePageContextValues['exercise'],
    code: {} as JikiscriptExercisePageContextValues['code'],
    resetEditorToStub: () => {},
    editorView: {} as EditorView | null,
    isSpotlightActive: false,
    exerciseLocalStorageData: {} as ExerciseLocalStorageData,
    setExerciseLocalStorageData: () => {},
  })

export default function JikiscriptExercisePageContextWrapper({
  children,
  value,
}: {
  children: React.ReactNode
  value: JikiscriptExercisePageContextValues
}) {
  return (
    <JikiscriptExercisePageContext.Provider value={value}>
      {children}
    </JikiscriptExercisePageContext.Provider>
  )
}
