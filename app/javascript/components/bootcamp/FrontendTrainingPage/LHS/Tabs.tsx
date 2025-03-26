import React from 'react'
import { Tab } from '@/components/common'
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
      <span data-text="HTML">HTML</span>
    </Tab>
  )
}

function CSSTab() {
  return (
    <Tab id="css" context={TabsContext}>
      <span data-text="CSS">CSS</span>
    </Tab>
  )
}
function JavaScriptTab() {
  return (
    <Tab id="javascript" context={TabsContext}>
      <span data-text="JavaScript">JavaScript</span>
    </Tab>
  )
}
