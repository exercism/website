import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from '../../RHS'
import { Chat } from './AiChat'

export function ChatPanel() {
  return (
    <Tab.Panel
      className="h-full"
      alwaysAttachToDOM
      id="chat"
      context={TabsContext}
    >
      <Chat />
    </Tab.Panel>
  )
}
