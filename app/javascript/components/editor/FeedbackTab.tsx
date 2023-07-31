import React from 'react'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'
import { GraphicalIcon } from '../common/GraphicalIcon'

export const FeedbackTab = (): JSX.Element => (
  <Tab id="feedback" context={TabsContext}>
    <GraphicalIcon icon="conversation-chat" />
    <span data-text="Feedback">Feedback</span>
  </Tab>
)
