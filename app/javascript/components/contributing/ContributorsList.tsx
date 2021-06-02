import React, { useCallback } from 'react'
import { PaginatedResult, Contributor } from '../types'
import { ContributorRow } from './contributors-list/ContributorRow'
import { PeriodButton } from './contributors-list/PeriodButton'
import { useIsMounted } from 'use-is-mounted'
import { useList } from '../../hooks/use-list'
import { usePaginatedRequestQuery, Request } from '../../hooks/request-query'
import { ResultsZone } from '../ResultsZone'
import { FetchingBoundary } from '../FetchingBoundary'
import { Pagination } from '../common'

const DEFAULT_ERROR = new Error('Unable to load contributors list')

export type Period = 'week' | 'month' | 'year' | undefined

export const ContributorsList = ({
  request: initialRequest,
}: {
  request: Request
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { request, setPage, setQuery } = useList(initialRequest)
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

  const setPeriod = useCallback(
    (period: Period) => {
      setQuery({ ...request.query, period: period })
    },
    [request.query, setQuery]
  )

  return (
    <div>
      <div className="c-search-bar">
        <div className="tabs">
          <PeriodButton
            period="week"
            setPeriod={setPeriod}
            current={request.query.period}
          >
            <span data-text="Last 7 days">Last 7 days</span>
          </PeriodButton>
          <PeriodButton
            period="month"
            setPeriod={setPeriod}
            current={request.query.period}
          >
            <span data-text="Last 30 days">Last 30 days</span>
          </PeriodButton>
          <PeriodButton
            period="year"
            setPeriod={setPeriod}
            current={request.query.period}
          >
            <span data-text="Last year">Last year</span>
          </PeriodButton>
          <PeriodButton
            period={undefined}
            setPeriod={setPeriod}
            current={request.query.period}
          >
            <span data-text="All time">All time</span>
          </PeriodButton>
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
