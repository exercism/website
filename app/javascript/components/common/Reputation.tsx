import React from 'react'
import { Icon } from './Icon'

export const Reputation = ({
  value,
  size,
  type = 'common',
}: {
  value: string
  size?: 'small'
  type?: 'primary' | 'common'
}): JSX.Element => {
  const classNames = [
    type === 'primary' ? 'c-primary-reputation' : 'c-reputation',
    size ? `--${size}` : '',
  ].filter((className) => className.length > 0)

  switch (type) {
    case 'primary':
      return (
        <div
          className={classNames.join(' ')}
          aria-label={`${value} reputation`}
        >
          <div className="--inner">
            <Icon icon="reputation" alt="Reputation" />
            <span>{value}</span>
          </div>
        </div>
      )
    case 'common':
      return (
        <div
          className={classNames.join(' ')}
          aria-label={`${value} reputation`}
        >
          <Icon icon="reputation" alt="Reputation" />
          <span>{value}</span>
        </div>
      )
  }
}
