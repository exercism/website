import React from 'react'
import { Tab } from '../../common/Tab'
import { TabsContext } from '../../Editor'
import { GraphicalIcon } from '../../common/GraphicalIcon'

export const ChatGptTab = (): JSX.Element => (
  <Tab id="chat-gpt" context={TabsContext}>
    <GraphicalIcon icon="automation" />
    <span data-text="ChatGPT">ChatGPT</span>
  </Tab>
)
