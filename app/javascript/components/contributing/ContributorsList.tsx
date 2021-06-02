import React from 'react'
import { PaginatedResult, Contributor } from '../types'
import { ContributorRow } from './contributors-list/ContributorRow'
import { useIsMounted } from 'use-is-mounted'
import { useList } from '../../hooks/use-list'
import { usePaginatedRequestQuery, Request } from '../../hooks/request-query'
import { ResultsZone } from '../ResultsZone'
import { FetchingBoundary } from '../FetchingBoundary'
import { Pagination } from '../common'

const DEFAULT_ERROR = new Error('Unable to load contributors list')

export const ContributorsList = ({
  request: initialRequest,
}: {
  request: Request
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { request, setPage } = useList(initialRequest)
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<PaginatedResult<readonly Contributor[]>>(
    ['contributors-list', request.endpoint, request.query],
    {
      ...request,
      options: { ...request.options },
    },
    isMountedRef
  )

  return (
    <div>
      <div className="c-search-bar">
        <div className="tabs">
          <div className="c-tab-2">
            <span data-text="Last 7 days">Last 7 days</span>
          </div>
          <div className="c-tab-2">
            <span data-text="Last 30 days">Last 30 days</span>
          </div>
          <div className="c-tab-2">
            <span data-text="Last year">Last year</span>
          </div>
          <div className="c-tab-2">
            <span data-text="All time">All time</span>
          </div>
        </div>
        {/* <TrackSwitcher size="small"></TrackSwitcher> */}
        <div className="c-select">
          <select>
            <option>Select a category....</option>
            <option value="building">Building</option>
            <option value="maintaining">Maintaining</option>
            <option value="authoring">Authoring</option>
            <option value="mentoring">Mentoring</option>
            <option value="publishing">Publishing</option>
          </select>
        </div>
      </div>

      <div className="contributors">
        <ResultsZone isFetching={isFetching}>
          <FetchingBoundary
            status={status}
            error={error}
            defaultError={DEFAULT_ERROR}
          >
            {resolvedData ? (
              <React.Fragment>
                {resolvedData.results.map((contributor) => (
                  <ContributorRow
                    contributor={contributor}
                    key={contributor.handle}
                  />
                ))}
                <Pagination
                  disabled={latestData === undefined}
                  current={request.query.page}
                  total={resolvedData.meta.totalPages}
                  setPage={setPage}
                />
              </React.Fragment>
            ) : null}
          </FetchingBoundary>
        </ResultsZone>
      </div>
    </div>
  )
}
