import React from 'react'
import { ContributionResults } from './ContributionResults'
import { SearchableList } from '../common/SearchableList'

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
  endpoint,
}: {
  endpoint: string
}): JSX.Element => {
  return (
    <SearchableList
      cacheKey="journey-contributions-list"
      endpoint={endpoint}
      placeholder="Search for a contribution"
      categories={CATEGORIES}
      ResultsComponent={ContributionResults}
    />
  )
}
