import React from 'react'
import { InstructionsPanel } from './InstructionsPanel'
import { OutputPanel } from './OutputPanel'

export function Panels() {
  return (
    <div className="panels h-100">
      <InstructionsPanel />
      <OutputPanel />
    </div>
  )
}
