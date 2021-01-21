import React from 'react'
import { SolutionResults } from './SolutionResults'
import { SearchableList } from '../common/SearchableList'

const CATEGORIES = [
  {
    value: 'status',
    label: 'Status',
    options: [
      { value: '', label: 'All' },
      { value: 'in_progress', label: 'In progress' },
      { value: 'completed', label: 'Completed' },
      { value: 'published', label: 'Completed and published' },
      { value: 'not_published', label: 'Completed but not published' },
    ],
  },
  {
    value: 'mentoring_status',
    label: 'Mentoring status',
    options: [
      { value: '', label: 'All' },
      { value: 'none', label: 'None' },
      { value: 'requested', label: 'Requested' },
      { value: 'in_progress', label: 'In Progress' },
      { value: 'completed', label: 'Completed' },
    ],
  },
]

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
      categories={CATEGORIES}
      ResultsComponent={SolutionResults}
    />
  )
}
