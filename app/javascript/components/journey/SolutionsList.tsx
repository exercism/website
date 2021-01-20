import React from 'react'
import { SolutionFilter } from './SolutionFilter'
import { SolutionResults } from './SolutionResults'
import { SearchableList } from '../common/SearchableList'

export const SolutionsList = ({
  endpoint,
}: {
  endpoint: string
}): JSX.Element => {
  return (
    <SearchableList
      cacheKey="journey-solutions-list"
      endpoint={endpoint}
      placeholder="Search for an exercise"
      FilterComponent={SolutionFilter}
      ResultsComponent={SolutionResults}
    />
  )
}
