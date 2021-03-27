import React, { useState } from 'react'
import { ExerciseWidget } from '../common'
import { Track } from '../types'
import { usePaginatedRequestQuery, Request } from '../../hooks/request-query'
import { Exercise, SolutionForStudent } from '../types'
import { useIsMounted } from 'use-is-mounted'
import { useList } from '../../hooks/use-list'
import { FetchingBoundary } from '../FetchingBoundary'

const DEFAULT_ERROR = new Error('Unable to load exercises')

type FilterValue =
  | 'published'
  | 'completed'
  | 'iterated'
  | 'started'
  | 'available'
  | 'locked'
  | null

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

    return this.exercise.isUnlocked ? 'available' : 'locked'
  }
}

class StatusFilter {
  values?: FilterValue[]
  title: string
  edClass?: string

  constructor(title: string, values?: FilterValue[], edClass?: string) {
    this.values = values
    this.title = title
    this.edClass = edClass
  }

  apply(results: Result[] | undefined) {
    if (results === undefined) {
      return []
    }

    if (this.values === undefined || this.values === null) {
      return results
    }

    return results.filter((result) => this.values!.includes(result.status))
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
      {filter.edClass ? <div className={`c-ed --${filter.edClass}`} /> : null}
      {filter.title}
      <div className="count">{filter.apply(results).length}</div>
    </button>
  )
}

const STATUS_FILTERS = [
  new StatusFilter('All Exercises'),
  new StatusFilter('Completed', ['published', 'completed'], 'c'),
  new StatusFilter('In Progress', ['iterated', 'started'], 'ip'),
  new StatusFilter('Available', ['available'], 'a'),
  new StatusFilter('Locked', ['locked'], 'l'),
]

export const ExerciseList = ({
  track,
  request: initialRequest,
}: {
  track: Track
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
              key={filter.title}
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
                  track={track}
                  size="medium"
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
