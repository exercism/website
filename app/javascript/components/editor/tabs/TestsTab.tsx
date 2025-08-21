import React from 'react'
import { Tab } from '../../common/Tab'
import { TabsContext } from '../../Editor'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const TestsTab = () => {
  const { t } = useAppTranslation('components/editor/tabs')
  return (
    <Tab id="tests" context={TabsContext}>
      <GraphicalIcon icon="tests" />
      <span data-text="Tests">{t('testsTab.tests')}</span>
    </Tab>
  )
}
