import React, { useContext } from 'react'
import { CSSEditor } from './CSSEditor'
import { HTMLEditor } from './HTMLEditor'
import { ControlButtons } from './ControlButtons'
import { CSSExercisePageContext } from '../CSSExercisePageContext'

export function LHS({
  getEditorValues,
}: {
  getEditorValues: () => { cssValue: string; htmlValue: string }
}) {
  return (
    <div className="page-body-lhs">
      <HTMLEditor />
      <CSSEditor />
      <ControlButtons getEditorValues={getEditorValues} />
    </div>
  )
}
