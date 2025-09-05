// i18n-key-prefix: outOfDateNotice
// i18n-namespace: components/track/iteration-summary
import React from 'react'
import { GraphicalIcon } from '../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const OutOfDateNotice = (): JSX.Element => {
  const { t } = useAppTranslation()
  return (
    <div className="--out-of-date">
      <GraphicalIcon icon="warning" />
      <div className="--status">{t('outOfDateNotice.outdated')}</div>
    </div>
  )
}
