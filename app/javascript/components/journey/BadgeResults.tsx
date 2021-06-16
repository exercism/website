import React from 'react'
import { RevealedBadge } from './RevealedBadge'
import { UnrevealedBadge } from './UnrevealedBadge'
import pluralize from 'pluralize'
import { Badge as BadgeProps } from '../types'
import { QueryKey } from 'react-query'
import { OrderSwitcher } from './badge-results/OrderSwitcher'

export type Order = 'unrevealed_first' | 'newest_first' | 'oldest_first'

const DEFAULT_ORDER = 'unrevealed_first'

export const BadgeResults = ({
  results,
  cacheKey,
  order,
  setOrder,
}: {
  results: BadgeProps[]
  cacheKey: QueryKey
  setOrder: (order: string) => void
  order: string
}): JSX.Element => {
  return (
    <div>
      <div className="results-title-bar">
        <h3>
          Showing {results.length} {pluralize('badge', results.length)}
        </h3>
        <OrderSwitcher
          value={(order || DEFAULT_ORDER) as Order}
          setValue={setOrder}
        />
      </div>
      <div className="badges">
        {results.map((badge) => {
          return badge.isRevealed ? (
            <RevealedBadge badge={badge} key={badge.id} />
          ) : (
            <UnrevealedBadge badge={badge} cacheKey={cacheKey} key={badge.id} />
          )
        })}
      </div>
    </div>
  )
}
