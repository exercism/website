import React from 'react'
import { RevealedBadge } from './RevealedBadge'
import { UnrevealedBadge } from './UnrevealedBadge'
import pluralize from 'pluralize'
import { Badge as BadgeProps } from '../types'
import { QueryKey } from 'react-query'

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
        <div className="c-select order">
          <select onChange={(e) => setOrder(e.target.value)} value={order}>
            <option value="unrevealed_first">Sort by Recommended</option>
            <option value="newest_first">Sort by Newest First</option>
            <option value="oldest_first">Sort by Oldest First</option>
          </select>
        </div>
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
