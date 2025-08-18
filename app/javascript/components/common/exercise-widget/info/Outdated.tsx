// i18n-key-prefix: info.outdated
// i18n-namespace: components/common/exercise-widget
import React from 'react'
import { Icon } from '../..'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const Outdated = (): JSX.Element => {
  const { t } = useAppTranslation('components/common/exercise-widget')
  return (
    <Icon
      className="--out-of-date"
      icon="warning"
      alt={t('info.outdated.solutionWasSolved')}
    />
  )
}
