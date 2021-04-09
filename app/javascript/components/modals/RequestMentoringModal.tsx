import React from 'react'
import { fromNow } from '../../utils/time'
import {
  GraphicalIcon,
  TrackIcon,
  ExerciseIcon,
  Icon,
  Pagination,
} from '../common'
import { Modal, ModalProps } from './Modal'
import { Request, usePaginatedRequestQuery } from '../../hooks/request-query'
import { useList } from '../../hooks/use-list'
import { useIsMounted } from 'use-is-mounted'
import { SolutionForStudent } from '../types'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import { Links } from '../student/RequestMentoringButton'

type PaginatedResult = {
  results: SolutionForStudent[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
  }
}

const DEFAULT_ERROR = new Error('Unable to pull exercises')

export const RequestMentoringModal = ({
  request: initialRequest,
  links,
  ...props
}: Omit<ModalProps, 'className'> & {
  request: Request
  links: Links
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { request, setPage, setCriteria } = useList(initialRequest)
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<PaginatedResult, Error | Response>(
    ['exercises-for-mentoring', request.query],
    request,
    isMountedRef
  )

  return (
    <Modal className="m-select-exercise-for-mentoring" {...props}>
      <h2>Selecct an exercise to request mentoring on</h2>
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
                    <a href={link} className="exercise" key={solution.id}>
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
              current={request.query.page}
              total={resolvedData.meta.totalPages}
              setPage={setPage}
            />
          </React.Fragment>
        ) : null}
      </FetchingBoundary>
    </Modal>
  )
}
