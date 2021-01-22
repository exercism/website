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
      cacheKey="journey-solutions-list"
      endpoint={endpoint}
      placeholder="Search for an exercise"
      categories={CATEGORIES}
      ResultsComponent={ContributionResults}
    />
  )
}
