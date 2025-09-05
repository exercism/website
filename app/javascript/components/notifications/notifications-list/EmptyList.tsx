import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const EmptyList = (): JSX.Element => {
  const { t } = useAppTranslation()
  return <div>{t('list.youHaveNoNotifications')}</div>
}
