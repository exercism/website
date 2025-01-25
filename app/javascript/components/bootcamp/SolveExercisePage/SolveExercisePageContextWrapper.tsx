import { EditorView } from '@codemirror/view'
import React from 'react'

import { createContext } from 'react'

type SolveExercisePageContextValues = Partial<
  Pick<SolveExercisePageProps, 'links' | 'solution' | 'exercise' | 'code'>
> & { resetEditorToStub?: () => void; editorView: EditorView | null }

export const SolveExercisePageContext =
  createContext<SolveExercisePageContextValues>({
    links: {} as SolveExercisePageContextValues['links'],
    solution: {} as SolveExercisePageContextValues['solution'],
    exercise: {} as SolveExercisePageContextValues['exercise'],
    code: {} as SolveExercisePageContextValues['code'],
    resetEditorToStub: () => {},
    editorView: {} as EditorView | null,
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
