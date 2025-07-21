import React from 'react'
import { Tab, GraphicalIcon } from '@/components/common'
import { TabsContext } from '@/components/Editor'

export const FeedbackTab = (): JSX.Element => (
  <Tab id="feedback" context={TabsContext}>
    <GraphicalIcon icon="conversation-chat" />
    <span data-text="Feedback">Feedback</span>
  </Tab>
)
