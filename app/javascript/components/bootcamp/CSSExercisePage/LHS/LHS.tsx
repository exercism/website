import React from 'react'
import { CSSEditor } from './CSSEditor'
import { HTMLEditor } from './HTMLEditor'
import { ControlButtons } from './ControlButtons'

export function LHS({
  defaultCode,
  getEditorValues,
}: {
  defaultCode: Record<'html' | 'css', string>
  getEditorValues: () => { cssValue: string; htmlValue: string }
}) {
  return (
    <div className="page-body-lhs">
      <HTMLEditor defaultCode={defaultCode.html} />
      <CSSEditor defaultCode={defaultCode.css} />
      <ControlButtons getEditorValues={getEditorValues} />
    </div>
  )
}
