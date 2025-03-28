import React from 'react'
import { CSSEditor } from './CSSEditor'
import { HTMLEditor } from './HTMLEditor'
import { ControlButtons } from './ControlButtons'

export function LHS() {
  return (
    <div className="page-body-lhs">
      <HTMLEditor />
      <CSSEditor />
      <ControlButtons />
    </div>
  )
}
