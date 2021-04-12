import React from 'react'
import { useIsMounted } from 'use-is-mounted'
import { Request, usePaginatedRequestQuery } from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import { Testimonial } from '../types'
import { RevealedTestimonial } from './testimonials-list/RevealedTestimonial'
import { UnrevealedTestimonial } from './testimonials-list/UnrevealedTestimonial'

type PaginatedResult = {
  results: readonly Testimonial[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
  }
}

const DEFAULT_ERROR = new Error('Unable to load testimonials')

export const TestimonialsList = ({
  request,
}: {
  request: Request
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { status, resolvedData, isFetching, error } = usePaginatedRequestQuery<
    PaginatedResult,
    Error | Response
  >(
    ['mentor-testimonials', request.endpoint, request.query],
    request,
    isMountedRef
  )

  return (
    <div className="lg-container">
      <article className="content">
        <div className="c-search-bar">
          <input
            className="--search"
            placeholder="Search by student name or testimonial"
          />
          <div className="c-select order">
            <select>
              <option>Sort by Newest First</option>
            </select>
          </div>
        </div>
        <div className="testimonials">
          <FetchingBoundary
            status={status}
            error={error}
            defaultError={DEFAULT_ERROR}
          >
            <ResultsZone isFetching={isFetching}>
              {resolvedData
                ? resolvedData.results.map((testimonial) => {
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
                  })
                : null}
            </ResultsZone>
          </FetchingBoundary>
        </div>
      </article>
    </div>
  )
}
