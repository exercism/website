import React from 'react'
import { ContributionResults } from './ContributionResults'
import { SearchableList } from '../common/SearchableList'
import { Request } from '../../hooks/request-query'

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

export const ContributionsList = ({
  request,
  isEnabled,
}: {
  request: Request
  isEnabled: boolean
}): JSX.Element => {
  return (
    <article className="reputation-tab theme-dark">
      <SearchableList
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
