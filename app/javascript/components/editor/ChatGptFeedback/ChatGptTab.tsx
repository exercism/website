import React from 'react'
import { Tab } from '../../common/Tab'
import { TabsContext } from '../../Editor'
import { GraphicalIcon } from '../../common/GraphicalIcon'

export const ChatGptTab = (): JSX.Element => (
  <Tab id="chatgpt" context={TabsContext}>
    <GraphicalIcon icon="automation" />
    <span data-text="ChatGpt">ChatGPT</span>
  </Tab>
)
