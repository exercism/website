import React, { useEffect, useState, useCallback } from 'react'
import { Request, usePaginatedRequestQuery } from '@/hooks/request-query'
import { useHistory, removeEmpty } from '@/hooks/use-history'
import { useList } from '@/hooks/use-list'
import { Pagination } from '../common'
import CommunitySolution from '../common/CommunitySolution'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import { TrackDropdown, OrderSelect } from './community-solutions-list'
import type {
  CommunitySolution as CommunitySolutionProps,
  PaginatedResult,
} from '../types'
import { scrollToTop } from '@/utils/scroll-to-top'

export type TrackData = {
  iconUrl: string
  title: string
  slug: string | null
  numSolutions: number
}

export type Order = 'most_starred' | 'newest_first' | 'oldest_first'

const DEFAULT_ERROR = new Error('Unable to pull solutions')
const DEFAULT_ORDER = 'most_starred'

export default function CommunitySolutionsList({
  request: initialRequest,
  tracks,
}: {
  request: Request
  tracks: TrackData[]
}): JSX.Element {
  const {
    request,
    setCriteria: setRequestCriteria,
    setPage,
    setOrder,
    setQuery,
  } = useList(initialRequest)
  const {
    status,
    data: resolvedData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<
    PaginatedResult<CommunitySolutionProps[]>,
    Error | Response
  >(
    ['profile-community-solution-list', request.endpoint, request.query],
    request
  )
  const [criteria, setCriteria] = useState(request.query?.criteria)

  const setTrack = useCallback(
    (slug) => {
      setQuery({ ...request.query, trackSlug: slug, page: undefined })
    },
    [request.query, setQuery]
  )

  useEffect(() => {
    const handler = setTimeout(() => {
      if (criteria === undefined || criteria === null) return
      setRequestCriteria(criteria)
    }, 200)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  useHistory({ pushOn: removeEmpty(request.query) })

  return (
    <div
      data-scroll-top-anchor="community-solutions-list"
      className="lg-container"
    >
      <div className="c-search-bar">
        <TrackDropdown
          tracks={tracks}
          value={request.query.trackSlug || ''}
          setValue={setTrack}
        />
        <input
          className="--search"
          onChange={(e) => {
            setCriteria(e.target.value)
          }}
          value={criteria || ''}
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
                      key={solution.uuid}
                      solution={solution}
                      context="profile"
                    />
                  )
                })}
              </div>
              <Pagination
                disabled={resolvedData === undefined}
                current={request.query.page || 1}
                total={resolvedData.meta.totalPages}
                setPage={(p) => {
                  setPage(p)
                  scrollToTop('community-solutions-list', 32)
                }}
              />
            </React.Fragment>
          ) : null}
        </FetchingBoundary>
      </ResultsZone>
    </div>
  )
}
