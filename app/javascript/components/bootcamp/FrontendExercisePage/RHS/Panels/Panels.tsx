import React from 'react'
import { InstructionsPanel } from './InstructionsPanel'
import { StudentOutputPanel } from './StudentOutputPanel'
import { ExpectedOutputPanel } from './ExpectedOutputPanel'
import { ConsolePanel } from './ConsolePanel'

export function Panels() {
  return (
    <div className="panels h-100 overflow-auto">
      <InstructionsPanel />
      <StudentOutputPanel />
      <ExpectedOutputPanel />
      <ConsolePanel />
    </div>
  )
}
