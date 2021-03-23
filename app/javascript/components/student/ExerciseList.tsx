import React, { useState } from 'react'
import { ExerciseWidget } from '../common'
import { usePaginatedRequestQuery, Request } from '../../hooks/request-query'
import { Exercise, SolutionForStudent } from '../types'
import { useIsMounted } from 'use-is-mounted'
import { useList } from '../../hooks/use-list'
import { FetchingBoundary } from '../FetchingBoundary'

const DEFAULT_ERROR = new Error('Unable to load exercises')

type FilterValue = 'completed' | 'in_progress' | 'available' | 'locked' | null

class Result {
  exercise: Exercise
  solution: SolutionForStudent | undefined

  constructor(exercise: Exercise, solution: SolutionForStudent | undefined) {
    this.exercise = exercise
    this.solution = solution
  }

  get status() {
    if (this.solution) {
      return this.solution.status
    }

    return this.exercise.isAvailable ? 'available' : 'locked'
  }
}

class StatusFilter {
  value: FilterValue
  title: string

  constructor(title: string, value: FilterValue) {
    this.value = value
    this.title = title
  }

  apply(results: Result[] | undefined) {
    if (results === undefined) {
      return []
    }

    if (this.value === null) {
      return results
    }

    return results.filter((result) => result.status === this.value)
  }
}

const Tab = ({
  filter,
  results,
  onClick,
  selected,
}: {
  filter: StatusFilter
  results: Result[] | undefined
  onClick: () => void
  selected: boolean
}) => {
  const classNames = ['c-tab', selected ? 'selected' : null]

  return (
    <button type="button" className={classNames.join(' ')} onClick={onClick}>
      {filter.title}
      <div className="count">{filter.apply(results).length}</div>
    </button>
  )
}

const STATUS_FILTERS = [
  new StatusFilter('All Exercises', null),
  new StatusFilter('Completed', 'completed'),
  new StatusFilter('In Progress', 'in_progress'),
  new StatusFilter('Available', 'available'),
  new StatusFilter('Locked', 'locked'),
]

export const ExerciseList = ({
  request: initialRequest,
}: {
  request: Request
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { request, setCriteria } = useList(initialRequest)
  const [statusFilter, setStatusFilter] = useState<StatusFilter>(
    STATUS_FILTERS[0]
  )
  const { status, resolvedData, isFetching, error } = usePaginatedRequestQuery<
    { solutions: SolutionForStudent[]; exercises: Exercise[] },
    Error | Response
  >(['exercise-list', request.endpoint, request.query], request, isMountedRef)

  const results = resolvedData?.exercises.map((exercise) => {
    const solution = resolvedData.solutions.find(
      (solution) => solution.exercise.slug === exercise.slug
    )

    return new Result(exercise, solution)
  })

  return (
    <div className="lg-container container">
      <div className="c-search-bar">
        <input
          onChange={(e) => {
            setCriteria(e.target.value)
          }}
          value={request.query.criteria || ''}
          type="text"
          className="--search"
          placeholder="Search by title"
        />
        {isFetching ? <span>Fetching</span> : null}
      </div>
      <div className="tabs">
        {STATUS_FILTERS.map((filter) => {
          return (
            <Tab
              key={filter.value}
              filter={filter}
              results={results}
              onClick={() => setStatusFilter(filter)}
              selected={filter === statusFilter}
            />
          )
        })}
      </div>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
      >
        {results && results.length > 0 ? (
          <div className="exercises">
            {statusFilter.apply(results).map((result) => {
              return (
                <ExerciseWidget
                  key={result.exercise.slug}
                  exercise={result.exercise}
                  size="large"
                  solution={result.solution}
                />
              )
            })}
          </div>
        ) : (
          <p>No exercises found</p>
        )}
      </FetchingBoundary>
    </div>
  )
}
