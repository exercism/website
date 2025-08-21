import React from 'react'
import { Tab, GraphicalIcon } from '@/components/common'
import { TabsContext } from '@/components/Editor'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const InstructionsTab = () => {
  const { t } = useAppTranslation('components/editor/tabs')
  return (
    <Tab id="instructions" context={TabsContext}>
      <GraphicalIcon icon="instructions" />
      <span data-text="Instructions">{t('instructionsTab.instructions')}</span>
    </Tab>
  )
}
