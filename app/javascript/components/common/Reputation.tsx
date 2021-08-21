import React from 'react'
import { Icon } from './Icon'

export const Reputation = ({
  value,
  size,
  type = 'common',
}: {
  value: string
  size?: 'small' | 'large'
  type?: 'primary' | 'common'
}): JSX.Element => {
  const classNames = [
    type === 'primary' ? 'c-primary-reputation' : 'c-reputation',
    size ? `--${size}` : '',
  ].filter((className) => className.length > 0)

  return (
    <div className={classNames.join(' ')} aria-label={`${value} reputation`}>
      <Icon icon="reputation" alt="Reputation" />
      <span>{value}</span>
    </div>
  )
}
