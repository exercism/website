import React from 'react'
import { SolutionResults } from './SolutionResults'
import { SearchableList } from '../common/SearchableList'
import { Request } from '../../hooks/request-query'

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
  request,
  isEnabled,
}: {
  request: Request
  isEnabled: boolean
}): JSX.Element => {
  return (
    <article className="solutions-tab theme-dark">
      <SearchableList
        cacheKey="journey-solutions-list"
        request={request}
        placeholder="Search for an exercise"
        categories={CATEGORIES}
        ResultsComponent={SolutionResults}
        isEnabled={isEnabled}
      />
    </article>
  )
}
