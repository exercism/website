import React, { useCallback } from 'react'
import { Request, usePaginatedRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { useList } from '../../hooks/use-list'
import { CommunitySolution as CommunitySolutionProps } from '../types'
import { CommunitySolution } from '../common/CommunitySolution'
import { Pagination } from '../common'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import { TrackDropdown } from './community-solutions-list/TrackDropdown'
import { OrderSelect } from './community-solutions-list/OrderSelect'

export type TrackData = {
  iconUrl: string
  title: string
  id: string | null
  numSolutions: number
}

type PaginatedResult = {
  results: CommunitySolutionProps[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
    unscopedTotal: number
  }
}

export type Order = 'newest_first' | 'oldest_first'

const DEFAULT_ERROR = new Error('Unable to pull solutions')
const DEFAULT_ORDER = 'newest_first'

export const CommunitySolutionsList = ({
  request: initialRequest,
  tracks,
}: {
  request: Request
  tracks: TrackData[]
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { request, setCriteria, setPage, setOrder, setQuery } = useList(
    initialRequest
  )
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

  const setTrack = useCallback(
    (slug) => {
      setQuery({ ...request.query, trackSlug: slug })
    },
    [request.query, setQuery]
  )

  return (
    <div className="lg-container">
      <div className="c-search-bar">
        <TrackDropdown
          tracks={tracks}
          value={request.query.trackSlug || null}
          setValue={setTrack}
        />
        <input
          className="--search"
          onChange={(e) => {
            setCriteria(e.target.value)
          }}
          value={request.query.criteria || ''}
          placeholder="Filter by exercise"
        />
        <OrderSelect
          value={request.query.order || DEFAULT_ORDER}
          setValue={setOrder}
        />
      </div>
      <ResultsZone isFetching={isFetching}>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        >
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
        </FetchingBoundary>
      </ResultsZone>
    </div>
  )
}
