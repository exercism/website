import { Tab, GraphicalIcon } from '@/components/common'
import React from 'react'
import { TabsContext } from './LHS'

export function Tabs() {
  return (
    <div className="tabs">
      <HTMLTab />
      <CSSTab />
      <JavaScriptTab />
    </div>
  )
}

function HTMLTab() {
  return (
    <Tab id="html" context={TabsContext}>
      <GraphicalIcon icon="instructions" />
      <span data-text="HTML">HTML</span>
    </Tab>
  )
}

function CSSTab() {
  return (
    <Tab id="css" context={TabsContext}>
      <GraphicalIcon icon="instructions" />
      <span data-text="CSS">CSS</span>
    </Tab>
  )
}
function JavaScriptTab() {
  return (
    <Tab id="javascript" context={TabsContext}>
      <GraphicalIcon icon="instructions" />
      <span data-text="JavaScript">JavaScript</span>
    </Tab>
  )
}
