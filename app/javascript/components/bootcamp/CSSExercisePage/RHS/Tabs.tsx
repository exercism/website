import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from './RHS'

export function Tabs() {
  return (
    <div className="tabs">
      <InstructionsTab />
      <ChatTab />
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

function ChatTab() {
  return (
    <Tab id="chat" context={TabsContext}>
      <span data-text="Chat">Chat</span>
    </Tab>
  )
}
