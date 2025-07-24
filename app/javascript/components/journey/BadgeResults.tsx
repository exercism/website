import React from 'react'
import { RevealedBadge } from './RevealedBadge'
import { UnrevealedBadge } from './UnrevealedBadge'
import pluralize from 'pluralize'
import { Badge as BadgeProps, PaginatedResult } from '../types'
import { QueryKey } from '@tanstack/react-query'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type Order = 'unrevealed_first' | 'newest_first' | 'oldest_first'

export const BadgeResults = ({
  data,
  cacheKey,
}: {
  data: PaginatedResult<BadgeProps[]>
  cacheKey: QueryKey
}): JSX.Element => {
  const { t } = useAppTranslation('components/journey')
  return (
    <div>
      <div className="results-title-bar">
        <h3>
          {t('badgeResults.showingBadges', {
            totalCount: data.meta.totalCount,
            badgeLabel: pluralize('badge', data.meta.totalCount),
          })}
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
