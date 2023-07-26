import React from 'react'
import { ExerciseWidget, Pagination } from '../../common'
import { ExerciseAuthorship } from '../../types'
import { FetchingBoundary } from '../../FetchingBoundary'
import { ResultsZone } from '../../ResultsZone'
import { useList } from '../../../hooks/use-list'
import { usePaginatedRequestQuery, Request } from '../../../hooks/request-query'

type PaginatedResult = {
  results: readonly ExerciseAuthorship[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
  }
}

const DEFAULT_ERROR = new Error('Unable to load authoring contributions')

export const AuthoringContributionsList = ({
  request: initialRequest,
}: {
  request: Request
}): JSX.Element => {
  const { request, setPage } = useList(initialRequest)
  const { status, resolvedData, latestData, isFetching, error } =
    usePaginatedRequestQuery<PaginatedResult, Error | Response>(
      [request.endpoint, request.query],
      request
    )

  return (
    <ResultsZone isFetching={isFetching}>
      <FetchingBoundary
        error={error}
        status={status}
        defaultError={DEFAULT_ERROR}
      >
        {resolvedData ? (
          <React.Fragment>
            <div className="authoring">
              <div className="exercises">
                {resolvedData.results.map((authorship) => {
                  return (
                    /*large*/
                    <ExerciseWidget
                      key={authorship.exercise.slug}
                      exercise={authorship.exercise}
                      track={authorship.track}
                    />
                  )
                })}
              </div>
            </div>
            <Pagination
              disabled={latestData === undefined}
              current={request.query.page || 1}
              total={resolvedData.meta.totalPages}
              setPage={setPage}
            />
          </React.Fragment>
        ) : null}
      </FetchingBoundary>
    </ResultsZone>
  )
}
