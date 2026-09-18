// i18n-namespace: components/common/Reputation.tsx
import React from 'react'
import { Icon } from './Icon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const Reputation = ({
  value,
  size,
  type = 'common',
}: {
  value: string
  size?: 'small' | 'large'
  type?: 'primary' | 'common'
}): JSX.Element => {
  const { t } = useAppTranslation('components/common/Reputation.tsx')
  const classNames = [
    type === 'primary' ? 'c-primary-reputation' : 'c-reputation',
    size ? `--${size}` : '',
  ].filter((className) => className.length > 0)

  return (
    <div
      className={classNames.join(' ')}
      aria-label={t('reputation.valueReputation', { value })}
    >
      <Icon icon="reputation" alt={t('reputation.reputation')} />
      <span>{value}</span>
    </div>
  )
}
