// i18n-key-prefix: info.outdated
// i18n-namespace: components/common/exercise-widget
import React from 'react'
import { Icon } from '../..'
import { useTranslation } from 'react-i18next'
const { t } = useTranslation('components/common/exercise-widget')

export const Outdated = (): JSX.Element => {
  return (
    <Icon
      className="--out-of-date"
      icon="warning"
      alt={t('info.outdated.solutionWasSolved')}
    />
  )
}
