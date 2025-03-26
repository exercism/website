import React from 'react'
import { InstructionsPanel } from './InstructionsPanel'
import { OutputPanel } from './OutputPanel'

export function Panels() {
  return (
    <div className="panels">
      <InstructionsPanel />
      <OutputPanel />
    </div>
  )
}
