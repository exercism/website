import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from './RHS'

export function Tabs() {
  return (
    <div className="tabs">
      <InstructionsTab />
      <OutputTab />
    </div>
  )
}

function InstructionsTab() {
  return (
    <Tab id="instructions" context={TabsContext}>
      <span data-text="Instructions">Instructions</span>
    </Tab>
  )
}

function OutputTab() {
  return (
    <Tab id="output" context={TabsContext}>
      <span data-text="Output">Output</span>
    </Tab>
  )
}
