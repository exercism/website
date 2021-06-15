import React, { useCallback, useState } from 'react'
import { useIsMounted } from 'use-is-mounted'
import { Request, usePaginatedRequestQuery } from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import { Testimonial } from '../types'
import { RevealedTestimonial } from './testimonials-list/RevealedTestimonial'
import { UnrevealedTestimonial } from './testimonials-list/UnrevealedTestimonial'
import { useList } from '../../hooks/use-list'
import { GraphicalIcon, Pagination } from '../common'
import { TrackDropdown } from './testimonials-list/TrackDropdown'
import { OrderSelect } from './testimonials-list/OrderSelect'

export type PaginatedResult = {
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

export type Order = 'unrevealed' | 'newest' | 'oldest'

const DEFAULT_ERROR = new Error('Unable to load testimonials')
const DEFAULT_ORDER = 'unrevealed'

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
  const cacheKey = ['mentor-testimonials', request.endpoint, request.query]
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<PaginatedResult, Error | Response>(
    cacheKey,
    request,
    isMountedRef
  )

  const setTrack = useCallback(
    (track) => {
      setQuery({ ...request.query, track: track })
    },
    [request.query, setQuery]
  )
  const [revealedTestimonials, setRevealedTestimonials] = useState<string[]>([])

  return (
    <div className="lg-container">
      <article className="content">
        <div className="c-search-bar">
          <TrackDropdown
            tracks={tracks}
            value={request.query.track}
            setValue={setTrack}
          />
          <input
            className="--search"
            placeholder="Search by student name or testimonial"
            value={request.query.criteria || ''}
            onChange={(e) => {
              setCriteria(e.target.value)
            }}
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
              resolvedData.results.length == 0 ? (
                <div className="no-testimonials">
                  <GraphicalIcon icon="testimonials" />
                  <h2>You currently have no testimonials</h2>
                  <p>
                    Testimonials are left by students on ending successful
                    mentoring discussions.
                  </p>
                </div>
              ) : (
                <React.Fragment>
                  <div className="testimonials">
                    {resolvedData.results.map((testimonial) => {
                      return testimonial.isRevealed ? (
                        <RevealedTestimonial
                          key={testimonial.id}
                          testimonial={testimonial}
                          isRevealed={revealedTestimonials.includes(
                            testimonial.id
                          )}
                        />
                      ) : (
                        <UnrevealedTestimonial
                          key={testimonial.id}
                          testimonial={testimonial}
                          cacheKey={cacheKey}
                          onRevealed={() =>
                            setRevealedTestimonials([
                              ...revealedTestimonials,
                              testimonial.id,
                            ])
                          }
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
              )
            ) : null}
          </FetchingBoundary>
        </ResultsZone>
      </article>
    </div>
  )
}
