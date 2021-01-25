import React from 'react'
import { Icon } from './Icon'

export const Reputation = ({
  value,
  type = 'common',
}: {
  value: string
  type?: 'primary' | 'common'
}): JSX.Element => {
  switch (type) {
    case 'primary':
      return (
        <div
          className="c-primary-reputation"
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
        <div className="c-reputation" aria-label={`${value} reputation`}>
          <Icon icon="reputation" alt="Reputation" />
          <span>{value}</span>
        </div>
      )
  }
}
