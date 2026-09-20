// i18n-key-prefix: assistantChatTab
// i18n-namespace: components/editor/AssistantChat
import React from 'react'
import { Tab } from '../../common/Tab'
import { TabsContext } from '../../Editor'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const AssistantChatTab = (): JSX.Element => {
  const { t } = useAppTranslation('components/editor/AssistantChat')
  const label = t('assistantChatTab.aiAssistant')

  return (
    <Tab id="assistant" context={TabsContext}>
      <GraphicalIcon icon="automation" />
      <span data-text={label}>{label}</span>
    </Tab>
  )
}
