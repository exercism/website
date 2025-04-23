import React, { useContext } from 'react'
import { CSSEditor } from './CSSEditor'
import { HTMLEditor } from './HTMLEditor'
import { ControlButtons } from './ControlButtons'
import { CSSExercisePageContext } from '../CSSExercisePageContext'

export function LHS() {
  const { code } = useContext(CSSExercisePageContext)
  return (
    <div className="page-body-lhs">
      {!code.shouldHideHtmlEditor && <HTMLEditor />}
      {!code.shouldHideCssEditor && <CSSEditor />}
      <ControlButtons />
    </div>
  )
}
