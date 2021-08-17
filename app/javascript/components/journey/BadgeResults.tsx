import React from 'react'
import { RevealedBadge } from './RevealedBadge'
import { UnrevealedBadge } from './UnrevealedBadge'
import pluralize from 'pluralize'
import { Badge as BadgeProps } from '../types'
import { QueryKey } from 'react-query'
import { PaginatedResult } from '../common/SearchableList'

export type Order = 'unrevealed_first' | 'newest_first' | 'oldest_first'

export const BadgeResults = ({
  data,
  cacheKey,
}: {
  data: PaginatedResult<BadgeProps>
  cacheKey: QueryKey
}): JSX.Element => {
  return (
    <div>
      <div className="results-title-bar">
        <h3>
          Showing {data.results.length}{' '}
          {pluralize('badge', data.results.length)}
        </h3>
      </div>
      <div className="badges">
        {data.results.map((badge) => {
          return badge.isRevealed ? (
            <RevealedBadge badge={badge} key={badge.uuid} />
          ) : (
            <UnrevealedBadge
              badge={badge}
              cacheKey={cacheKey}
              key={badge.uuid}
            />
          )
        })}
      </div>
    </div>
  )
}
