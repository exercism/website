import React, { useCallback } from 'react'
import { Pagination, TrackSelect } from '@/components/common'
import type { PaginatedResult, Contributor, Track } from '@/components/types'
import { ResultsZone } from '@/components/ResultsZone'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { useQueryParams, useList, useDeepMemo, useScrollToTop } from '@/hooks'
import { usePaginatedRequestQuery, type Request } from '@/hooks/request-query'
import {
  ContributorRow,
  PeriodButton,
  CategorySwitcher,
} from './contributors-list'

const DEFAULT_ERROR = new Error('Unable to load contributors list')

export type Period = 'week' | 'month' | 'year' | undefined
export type Category =
  | 'building'
  | 'maintaining'
  | 'authoring'
  | 'mentoring'
  | undefined

type QueryValueTypes = {
  trackSlug: string
  period: Period
  category: Category
}

export default function ContributorsList({
  request: initialRequest,
  tracks,
}: {
  request: Request
  tracks: readonly Track[]
}): JSX.Element {
  const { request, setPage, setQuery } = useList(initialRequest)
  const { status, resolvedData, latestData, isFetching, error } =
    usePaginatedRequestQuery<PaginatedResult<readonly Contributor[]>>(
      ['contributors-list', request.endpoint, request.query],
      {
        ...request,
        options: { ...request.options },
      }
    )

  const requestQuery = useDeepMemo(request.query)
  const setQueryValue = useCallback(
    <K extends keyof QueryValueTypes>(key: K, value: QueryValueTypes[K]) => {
      setQuery({ ...requestQuery, [key]: value, page: undefined })
    },
    [requestQuery, setQuery]
  )

  const track =
    tracks.find((t) => t.slug === request.query.trackSlug) || tracks[0]

  const scrollToTopRef = useScrollToTop<HTMLDivElement>(request.query.page)
  useQueryParams(request.query)

  return (
    <div>
      <div className="c-search-bar" ref={scrollToTopRef}>
        <div className="tabs overflow-x-auto">
          <PeriodButton
            period="week"
            setPeriod={(period) => setQueryValue('period', period)}
            current={request.query.period}
          >
            <span data-text="This week">This week</span>
          </PeriodButton>
          <PeriodButton
            period="month"
            setPeriod={(period) => setQueryValue('period', period)}
            current={request.query.period}
          >
            <span data-text="Last 30 days">Last 30 days</span>
          </PeriodButton>
          <PeriodButton
            period="year"
            setPeriod={(period) => setQueryValue('period', period)}
            current={request.query.period}
          >
            <span data-text="Last year">Last year</span>
          </PeriodButton>
          <PeriodButton
            period={undefined}
            setPeriod={(period) => setQueryValue('period', period)}
            current={request.query.period}
          >
            <span data-text="All time">All time</span>
          </PeriodButton>
        </div>
        <div className="hidden lg:flex items-center ml-auto">
          <TrackSelect
            tracks={tracks}
            value={track}
            setValue={(track) => setQueryValue('trackSlug', track.slug)}
            size="single"
          />
          <CategorySwitcher
            value={request.query.category}
            setValue={(category) => setQueryValue('category', category)}
          />
        </div>
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
                current={request.query.page || 1}
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
