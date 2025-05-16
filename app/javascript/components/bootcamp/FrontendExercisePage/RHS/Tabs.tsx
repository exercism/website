import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from './RHS'

export function Tabs() {
  return (
    <div className="tabs">
      <InstructionsTab />
      <OutputTab />
      <ExpectedTab />
      <ConsoleTab />
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

function ExpectedTab() {
  return (
    <Tab id="expected" context={TabsContext}>
      <span data-text="Expected">Expected</span>
    </Tab>
  )
}

function ConsoleTab() {
  return (
    <Tab id="console" context={TabsContext}>
      <span data-text="Console">Console</span>
    </Tab>
  )
}
