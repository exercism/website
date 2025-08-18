import React from 'react'
import { GraphicalIcon } from '../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const TotalReputation = ({
  handle,
  reputation,
}: {
  handle?: string
  reputation: number
}): JSX.Element => {
  const { t } = useAppTranslation('components/profile/contributions-summary')
  const address = handle
    ? t('totalReputation.addressHas', { handle })
    : t('totalReputation.youHave')

  return (
    <div className="c-primary-reputation --large">
      {address}
      <GraphicalIcon icon="reputation" />
      {reputation.toLocaleString()} {t('totalReputation.reputation')}
    </div>
  )
}
