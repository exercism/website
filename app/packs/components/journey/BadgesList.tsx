import React from 'react'
import { BadgeResults } from './BadgeResults'
import { FilterCategory, SearchableList } from '../common/SearchableList'
import { Request } from '../../hooks/request-query'

const CATEGORIES: FilterCategory[] = []

export const BadgesList = ({
  request,
  isEnabled,
}: {
  request: Request
  isEnabled: boolean
}): JSX.Element => {
  return (
    <article className="badges-tab theme-dark">
      <SearchableList
        cacheKey="journey-badges-list"
        request={request}
        placeholder="Search for a badge"
        categories={CATEGORIES}
        ResultsComponent={BadgeResults}
        isEnabled={isEnabled}
      />
    </article>
  )
}
