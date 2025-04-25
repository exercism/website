import React from 'react'
import { CSSPanel } from './CSSPanel/CSSPanel'
import { HTMLPanel } from './HTMLPanel/HTMLPanel'
import { JavaScriptPanel } from './JavaScriptPanel/JavaScriptPanel'

export const EDITOR_HEIGHT = 'calc(100vh - 150px)'

export function Panels() {
  return (
    <div className="c-code-pane">
      <HTMLPanel />
      <CSSPanel />
      <JavaScriptPanel />
    </div>
  )
}
