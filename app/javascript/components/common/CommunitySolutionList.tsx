import React from 'react'
import { Request, usePaginatedRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { useList } from '../../hooks/use-list'
import {
  CommunitySolution as CommunitySolutionProps,
  CommunitySolutionContext,
} from '../types'
import { CommunitySolution } from './CommunitySolution'
import { Pagination } from '.'
import { FetchingBoundary } from '../FetchingBoundary'
import pluralize from 'pluralize'
import { FetchingOverlay } from '../FetchingOverlay'

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

export const CommunitySolutionList = ({
  request: initialRequest,
  context,
}: {
  request: Request
  context: CommunitySolutionContext
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
    ['community-solution-list', request.endpoint, request.query],
    request,
    isMountedRef
  )

  return (
    <div className="lg-container">
      {resolvedData ? (
        <h2>
          {resolvedData.meta.unscopedTotal}{' '}
          {pluralize('person', resolvedData.meta.unscopedTotal)} published
          solutions
        </h2>
      ) : null}
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
        <FetchingOverlay isFetching={isFetching}>
          {resolvedData ? (
            <React.Fragment>
              <div className="solutions">
                {resolvedData.results.map((solution) => {
                  return (
                    <CommunitySolution
                      key={solution.id}
                      solution={solution}
                      context={context}
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
        </FetchingOverlay>
      </FetchingBoundary>
    </div>
  )
}
