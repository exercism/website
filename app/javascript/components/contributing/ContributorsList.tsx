import React, { useCallback } from 'react'
import { PaginatedResult, Contributor, Track } from '../types'
import { ContributorRow } from './contributors-list/ContributorRow'
import { PeriodButton } from './contributors-list/PeriodButton'
import { useIsMounted } from 'use-is-mounted'
import { useList } from '../../hooks/use-list'
import { usePaginatedRequestQuery, Request } from '../../hooks/request-query'
import { ResultsZone } from '../ResultsZone'
import { FetchingBoundary } from '../FetchingBoundary'
import { Pagination } from '../common'
import { TrackSwitcher } from '../common/TrackSwitcher'
import { CategorySwitcher } from './contributors-list/CategorySwitcher'

const DEFAULT_ERROR = new Error('Unable to load contributors list')

export type Period = 'week' | 'month' | 'year' | undefined
export type Category =
  | 'building'
  | 'maintaining'
  | 'authoring'
  | 'mentoring'
  | 'publishing'
  | undefined

export const ContributorsList = ({
  request: initialRequest,
  tracks,
}: {
  request: Request
  tracks: readonly Track[]
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

  const setCategory = useCallback(
    (category: Category) => {
      setQuery({ ...request.query, category: category })
    },
    [request.query, setQuery]
  )

  const setTrack = useCallback(
    (track: Track) => {
      setQuery({ ...request.query, track: track.id })
    },
    [request.query, setQuery]
  )
  const track = tracks.find((t) => t.id === request.query.track) || tracks[0]

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
        <TrackSwitcher tracks={tracks} value={track} setValue={setTrack} />
        <CategorySwitcher
          value={request.query.category}
          setValue={setCategory}
        />
      </div>

      <ResultsZone isFetching={isFetching}>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        >
          {resolvedData ? (
            <>
              <div className="contributors">
                {resolvedData.results.map((contributor) => (
                  <ContributorRow
                    contributor={contributor}
                    key={contributor.handle}
                  />
                ))}
              </div>
              <Pagination
                disabled={latestData === undefined}
                current={request.query.page}
                total={resolvedData.meta.totalPages}
                setPage={setPage}
              />
            </>
          ) : null}
        </FetchingBoundary>
      </ResultsZone>
    </div>
  )
}
