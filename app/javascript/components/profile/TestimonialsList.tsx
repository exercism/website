import React, { useState, useCallback } from 'react'
import { Request, usePaginatedRequestQuery, useList } from '@/hooks'
import { Pagination } from '../common'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import { PaginatedResult, Testimonial as TestimonialProps } from '../types'
import { Testimonial } from './testimonials-list/Testimonial'

const DEFAULT_ERROR = new Error('Unable to load testimonials')

export const TestimonialsList = ({
  request: initialRequest,
  defaultSelected,
}: {
  request: Request
  defaultSelected: string | null
}): JSX.Element => {
  const [selected, setSelected] = useState<string | null>(defaultSelected)

  const { request, setPage } = useList(initialRequest)
  const { resolvedData, isFetching, status, error, latestData } =
    usePaginatedRequestQuery<PaginatedResult<TestimonialProps[]>>(
      ['profile-testimonials-list-key', request.endpoint, request.query],
      request
    )

  const handleTestimonialOpen = useCallback(
    (uuid: string) => {
      return () => {
        setSelected(uuid)
      }
    },
    [setSelected]
  )

  const handleTestimonialClose = useCallback(() => {
    setSelected(null)
  }, [setSelected])

  return (
    <ResultsZone isFetching={isFetching}>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
      >
        {resolvedData ? (
          <>
            <div className="testimonials">
              {resolvedData.results.map((t) => {
                return (
                  <Testimonial
                    testimonial={t}
                    open={t.uuid === selected}
                    onClick={handleTestimonialOpen(t.uuid)}
                    onClose={handleTestimonialClose}
                    key={t.uuid}
                  />
                )
              })}
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
  )
}
