import React from 'react'
import { CSSEditor } from './CSSEditor'
import { HTMLEditor } from './HTMLEditor'

export function LHS() {
  return (
    <div className="page-body-lhs">
      <HTMLEditor />
      <CSSEditor />
    </div>
  )
}
