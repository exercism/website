import React, { useCallback, useState, useEffect } from 'react'
import {
  usePaginatedRequestQuery,
  useHistory,
  removeEmpty,
  useList,
  type Request as BaseRequest,
  useScrollToTop,
} from '@/hooks'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { ResultsZone } from '@/components/ResultsZone'
import { GraphicalIcon, Pagination } from '@/components/common'
import {
  RevealedTestimonial,
  OrderSelect,
  TrackDropdown,
  UnrevealedTestimonial,
} from './testimonials-list'
import type {
  PaginatedResult as DefaultPaginatedResult,
  SharePlatform,
  Testimonial,
} from '@/components/types'

export type PaginatedResult = DefaultPaginatedResult<Testimonial[]>
export type Track = {
  slug: string
  title: string
  iconUrl: string
}

export type Order = 'unrevealed' | 'newest' | 'oldest'

export type Request = BaseRequest<{
  criteria?: string
  order?: string
  trackSlug?: string
  page?: number
}>

const DEFAULT_ERROR = new Error('Unable to load testimonials')
const DEFAULT_ORDER = 'unrevealed'

export const TestimonialsList = ({
  request: initialRequest,
  tracks,
  platforms,
}: {
  request: Request
  tracks: readonly Track[]
  platforms: readonly SharePlatform[]
}): JSX.Element => {
  const {
    request,
    setQuery,
    setCriteria: setRequestCriteria,
    setPage,
    setOrder,
  } = useList(initialRequest)
  const [criteria, setCriteria] = useState(request.query?.criteria || '')
  const cacheKey = [
    'mentor-testimonials',
    request.endpoint,
    removeEmpty(request.query),
  ]
  const { status, resolvedData, latestData, isFetching, error } =
    usePaginatedRequestQuery<PaginatedResult, Error | Response>(cacheKey, {
      ...request,
      query: removeEmpty(request.query),
    })

  const setTrack = useCallback(
    (trackSlug) => {
      setQuery({ ...request.query, trackSlug: trackSlug, page: undefined })
    },
    [request.query, setQuery]
  )
  const [revealedTestimonials, setRevealedTestimonials] = useState<string[]>([])

  useHistory({ pushOn: removeEmpty(request.query) })

  useEffect(() => {
    const handler = setTimeout(() => {
      setRequestCriteria(criteria)
    }, 200)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  const scrollToTopRef = useScrollToTop<HTMLDivElement>(request.query.page)

  return (
    <div className="lg-container">
      <article className="content">
        <div className="c-search-bar" ref={scrollToTopRef}>
          <TrackDropdown
            tracks={tracks}
            value={request.query.trackSlug || ''}
            setValue={setTrack}
          />
          <input
            className="--search"
            placeholder="Search by student name or testimonial"
            value={criteria}
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
                          key={testimonial.uuid}
                          testimonial={testimonial}
                          cacheKey={cacheKey}
                          isRevealed={revealedTestimonials.includes(
                            testimonial.uuid
                          )}
                          platforms={platforms}
                        />
                      ) : (
                        <UnrevealedTestimonial
                          key={testimonial.uuid}
                          testimonial={testimonial}
                          cacheKey={cacheKey}
                          onRevealed={() =>
                            setRevealedTestimonials([
                              ...revealedTestimonials,
                              testimonial.uuid,
                            ])
                          }
                          platforms={platforms}
                        />
                      )
                    })}
                  </div>
                </React.Fragment>
              )
            ) : null}
          </FetchingBoundary>
        </ResultsZone>
      </article>
      {resolvedData ? (
        <Pagination
          disabled={latestData === undefined}
          current={request.query.page || 1}
          total={resolvedData.meta.totalPages}
          setPage={setPage}
        />
      ) : null}
    </div>
  )
}
