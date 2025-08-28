// i18n-key-prefix: chatGptTab
// i18n-namespace: components/editor/ChatGptFeedback
import React from 'react'
import { Tab } from '../../common/Tab'
import { TabsContext } from '../../Editor'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const ChatGptTab = (): JSX.Element => {
  return (
    <Tab id="chat-gpt" context={TabsContext}>
      <GraphicalIcon icon="automation" />
      <span data-text="ChatGPT">ChatGPT</span>
    </Tab>
  )
}
