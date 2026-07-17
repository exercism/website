import React from 'react'
import { Tab } from '../../common/Tab'
import { TabsContext } from '../../Editor'
import { GraphicalIcon } from '../../common/GraphicalIcon'

export const AssistantChatTab = (): JSX.Element => {
  return (
    <Tab id="assistant" context={TabsContext}>
      <GraphicalIcon icon="automation" />
      <span data-text="AI Assistant">AI Assistant</span>
    </Tab>
  )
}
