import React, { useCallback } from 'react'
import { useIsMounted } from 'use-is-mounted'
import { Request, usePaginatedRequestQuery } from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import { Testimonial } from '../types'
import { RevealedTestimonial } from './testimonials-list/RevealedTestimonial'
import { UnrevealedTestimonial } from './testimonials-list/UnrevealedTestimonial'
import { useList } from '../../hooks/use-list'
import { Pagination } from '../common/Pagination'
import { TrackDropdown } from './testimonials-list/TrackDropdown'

type PaginatedResult = {
  results: readonly Testimonial[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
  }
}

export type Track = {
  title: string
  slug: string
  iconUrl: string
}

const DEFAULT_ERROR = new Error('Unable to load testimonials')

export const TestimonialsList = ({
  request: initialRequest,
  tracks,
}: {
  request: Request
  tracks: readonly Track[]
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { request, setQuery, setCriteria, setPage, setOrder } = useList(
    initialRequest
  )
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<PaginatedResult, Error | Response>(
    ['mentor-testimonials', request.endpoint, request.query],
    request,
    isMountedRef
  )

  const setTrack = useCallback(
    (track) => {
      setQuery({ ...request.query, track: track })
    },
    [request.query, setQuery]
  )

  return (
    <div className="lg-container">
      <article className="content">
        <TrackDropdown
          tracks={tracks}
          value={request.query.track}
          setValue={setTrack}
        />
        <div className="c-search-bar">
          <input
            className="--search"
            placeholder="Search by student name or testimonial"
            value={request.query.criteria || ''}
            onChange={(e) => {
              setCriteria(e.target.value)
            }}
          />
          <div className="c-select order">
            <select
              value={request.query.order || 'newest'}
              onChange={(e) => setOrder(e.target.value)}
            >
              <option value="newest">Sort by Newest First</option>
              <option value="oldest">Sort by Oldest First</option>
            </select>
          </div>
        </div>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        >
          <ResultsZone isFetching={isFetching}>
            {resolvedData ? (
              <React.Fragment>
                <div className="testimonials">
                  {resolvedData.results.map((testimonial) => {
                    return testimonial.isRevealed ? (
                      <RevealedTestimonial
                        key={testimonial.id}
                        {...testimonial}
                      />
                    ) : (
                      <UnrevealedTestimonial
                        key={testimonial.id}
                        {...testimonial}
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
      </article>
    </div>
  )
}
