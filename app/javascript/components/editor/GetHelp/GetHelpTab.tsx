// i18n-key-prefix: getHelpTab
// i18n-namespace: components/editor/GetHelp
import React from 'react'
import { Tab } from '../../common/Tab'
import { TabsContext } from '../../Editor'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const GetHelpTab = (): JSX.Element => {
  const { t } = useAppTranslation('components/editor/GetHelp')
  return (
    <Tab id="get-help" context={TabsContext}>
      <GraphicalIcon icon="help" />
      <span data-text="Get Help">{t('getHelpTab.getHelp')}</span>
    </Tab>
  )
}
