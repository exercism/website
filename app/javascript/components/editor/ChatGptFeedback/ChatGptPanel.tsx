import React from 'react'
import { TabsContext } from '@/components/Editor'
import { Tab } from '@/components/common'

export type GetHelpPanelProps = {
  children?: React.ReactChild
}

export function ChatGptPanel({ children }: GetHelpPanelProps): JSX.Element {
  return (
    <Tab.Panel id="chat-gpt" context={TabsContext}>
      {children}
    </Tab.Panel>
  )
}
