import React from 'react'
import { fromNow } from '@/utils'
import { type Request, usePaginatedRequestQuery, useList } from '@/hooks'
import {
  GraphicalIcon,
  TrackIcon,
  ExerciseIcon,
  Icon,
  Pagination,
} from '../common'
import { Modal, type ModalProps } from './Modal'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import type { Links } from '../student/RequestMentoringButton'
import type { PaginatedResult, SolutionForStudent } from '../types'

const DEFAULT_ERROR = new Error('Unable to pull exercises')

export const RequestMentoringModal = ({
  request: initialRequest,
  links,
  ...props
}: Omit<ModalProps, 'className'> & {
  request: Request
  links: Links
}): JSX.Element => {
  const { request, setPage, setCriteria } = useList(initialRequest)
  const { status, resolvedData, latestData, isFetching, error } =
    usePaginatedRequestQuery<
      PaginatedResult<SolutionForStudent[]>,
      Error | Response
    >(['exercises-for-mentoring', request.query], request)

  return (
    <Modal
      closeButton={true}
      className="m-select-exercise-for-mentoring"
      {...props}
    >
      <h2>Select an exercise to request mentoring on</h2>
      <div className="c-search-bar">
        <input
          value={request.query.criteria || ''}
          onChange={(e) => {
            setCriteria(e.target.value)
          }}
          type="text"
          className="--search"
          placeholder="Search exercise by name"
        />
      </div>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
      >
        {resolvedData ? (
          <React.Fragment>
            <ResultsZone isFetching={isFetching}>
              <div className="exercises">
                {resolvedData.results.map((solution) => {
                  const link = links.mentorRequest
                    .replace('$EXERCISE_SLUG', solution.exercise.slug)
                    .replace('$TRACK_SLUG', solution.track.slug)
                  return (
                    <a href={link} className="exercise" key={solution.uuid}>
                      <TrackIcon
                        iconUrl={solution.track.iconUrl}
                        title={solution.track.title}
                      />
                      <ExerciseIcon
                        iconUrl={solution.exercise.iconUrl}
                        title={solution.exercise.iconUrl}
                      />
                      <div className="exercise-title">
                        {solution.exercise.title}
                      </div>
                      <div className="num-iterations">
                        <Icon icon="iteration" alt="Number of iterations" />
                        {solution.numIterations}
                      </div>
                      <div className="last-touched">
                        {fromNow(solution.updatedAt)}
                      </div>
                      <GraphicalIcon
                        icon="chevron-right"
                        className="action-icon"
                      />
                    </a>
                  )
                })}
              </div>
            </ResultsZone>
            <Pagination
              disabled={latestData === undefined}
              current={request.query.page || 1}
              total={resolvedData.meta.totalPages}
              setPage={setPage}
            />
          </React.Fragment>
        ) : null}
      </FetchingBoundary>
    </Modal>
  )
}
