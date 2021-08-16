import React from 'react'
import { ContributionResults } from './ContributionResults'
import { SearchableList } from '../common/SearchableList'
import { Request } from '../../hooks/request-query'
import { Contribution } from '../types'

const CATEGORIES = [
  {
    value: 'category',
    label: 'Awarded For',
    options: [
      { value: '', label: 'Anything' },
      { value: 'building', label: 'Building Exercism' },
      { value: 'authoring', label: 'Contributing to Exercises' },
      { value: 'mentoring', label: 'Mentoring' },
    ],
  },
]

export type APIResult = {
  results: Contribution[]
  meta: {
    currentPage: number
    totalPages: number
    links: {
      markAllAsSeen: string
    }
  }
}

export const ContributionsList = ({
  request,
  isEnabled,
}: {
  request: Request
  isEnabled: boolean
}): JSX.Element => {
  return (
    <article className="reputation-tab theme-dark">
      <SearchableList<Contribution, APIResult>
        cacheKey="journey-contributions-list"
        request={request}
        placeholder="Search for a contribution"
        categories={CATEGORIES}
        ResultsComponent={ContributionResults}
        isEnabled={isEnabled}
      />
    </article>
  )
}
