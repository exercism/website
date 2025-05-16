import React from 'react'
import { InstructionsPanel } from './InstructionsPanel'
import { OutputPanel } from './OutputPanel'
import { ExpectedPanel } from './ExpectedPanel'

export function Panels() {
  return (
    <div className="panels h-100 overflow-auto">
      <InstructionsPanel />
      <OutputPanel />
      <ExpectedPanel />
    </div>
  )
}
