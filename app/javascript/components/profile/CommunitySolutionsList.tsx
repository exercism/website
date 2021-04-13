import React from 'react'
import { Request, usePaginatedRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { useList } from '../../hooks/use-list'
import { CommunitySolution as CommunitySolutionProps } from '../types'
import { CommunitySolution } from '../common/CommunitySolution'
import { Pagination } from '../common'
import { FetchingBoundary } from '../FetchingBoundary'
import pluralize from 'pluralize'
import { ResultsZone } from '../ResultsZone'

type PaginatedResult = {
  results: CommunitySolutionProps[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
    unscopedTotal: number
  }
}

const DEFAULT_ERROR = new Error('Unable to pull solutions')

export const CommunitySolutionsList = ({
  request: initialRequest,
}: {
  request: Request
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { request, setCriteria, setPage } = useList(initialRequest)
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<PaginatedResult, Error | Response>(
    ['profile-community-solution-list', request.endpoint, request.query],
    request,
    isMountedRef
  )

  return (
    <div className="lg-container">
      <div className="c-search-bar">
        <input
          className="--search"
          onChange={(e) => {
            setCriteria(e.target.value)
          }}
          value={request.query.criteria || ''}
          placeholder="Search by user"
        />
      </div>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
      >
        <ResultsZone isFetching={isFetching}>
          {resolvedData ? (
            <React.Fragment>
              <div className="solutions">
                {resolvedData.results.map((solution) => {
                  return (
                    <CommunitySolution
                      key={solution.id}
                      solution={solution}
                      context="profile"
                    />
                  )
                })}
              </div>
              <Pagination
                disabled={latestData === undefined}
                current={request.query.page}
                total={resolvedData.meta.totalPages}
                setPage={setPage}
              />
            </React.Fragment>
          ) : null}
        </ResultsZone>
      </FetchingBoundary>
    </div>
  )
}
