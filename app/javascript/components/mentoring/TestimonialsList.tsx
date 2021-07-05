import React, { useCallback, useState, useEffect } from 'react'
import { useIsMounted } from 'use-is-mounted'
import {
  Request as BaseRequest,
  usePaginatedRequestQuery,
} from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import { Testimonial } from '../types'
import { RevealedTestimonial } from './testimonials-list/RevealedTestimonial'
import { UnrevealedTestimonial } from './testimonials-list/UnrevealedTestimonial'
import { useList } from '../../hooks/use-list'
import { GraphicalIcon, Pagination } from '../common'
import { TrackDropdown } from './testimonials-list/TrackDropdown'
import { OrderSelect } from './testimonials-list/OrderSelect'
import { useHistory, removeEmpty } from '../../hooks/use-history'

export type PaginatedResult = {
  results: readonly Testimonial[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
  }
}

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
}: {
  request: Request
  tracks: readonly Track[]
}): JSX.Element => {
  const isMountedRef = useIsMounted()
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
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<PaginatedResult, Error | Response>(
    cacheKey,
    {
      ...request,
      query: removeEmpty(request.query),
    },
    isMountedRef
  )

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

  return (
    <div className="lg-container">
      <article className="content">
        <div className="c-search-bar">
          <TrackDropdown
            tracks={tracks}
            value={request.query.trackSlug}
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
                          isRevealed={revealedTestimonials.includes(
                            testimonial.uuid
                          )}
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
