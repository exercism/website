import React from 'react'
import { ExerciseWidget } from '../common'
import { usePaginatedRequestQuery, Request } from '../../hooks/request-query'
import { Exercise, SolutionForStudent } from '../types'
import { useIsMounted } from 'use-is-mounted'
import { useList } from '../../hooks/use-list'
import { FetchingBoundary } from '../FetchingBoundary'

const DEFAULT_ERROR = new Error('Unable to load exercises')

export const ExerciseList = ({
  request: initialRequest,
}: {
  request: Request
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { request, setCriteria } = useList(initialRequest)
  const { status, resolvedData, isFetching, error } = usePaginatedRequestQuery<
    { solutions: SolutionForStudent[]; exercises: Exercise[] },
    Error | Response
  >(['exercise-list', request.endpoint, request.query], request, isMountedRef)

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
        <div className="c-tab selected">
          All Exercises
          <div className="count">160</div>
        </div>
        <div className="c-tab">
          Completed
          <div className="count">14</div>
        </div>
        <div className="c-tab">
          In Progress
          <div className="count">29</div>
        </div>
        <div className="c-tab">
          Available
          <div className="count">37</div>
        </div>
        <div className="c-tab">
          Locked
          <div className="count">100</div>
        </div>
      </div>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
      >
        {resolvedData ? (
          <div className="exercises">
            {resolvedData.exercises.map((exercise) => {
              const solution = resolvedData.solutions.find(
                (solution) => solution.exercise.slug === exercise.slug
              )

              return (
                <ExerciseWidget
                  key={exercise.slug}
                  exercise={exercise}
                  size="large"
                  solution={solution}
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
