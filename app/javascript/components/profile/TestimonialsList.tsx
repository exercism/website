import React, { useState, useCallback } from 'react'
import { useList, useScrollToTop } from '@/hooks'
import { usePaginatedRequestQuery, type Request } from '@/hooks/request-query'
import { Pagination } from '@/components/common'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { ResultsZone } from '@/components/ResultsZone'
import { Testimonial } from './testimonials-list/Testimonial'
import type {
  PaginatedResult,
  Testimonial as TestimonialProps,
} from '@/components/types'

const DEFAULT_ERROR = new Error('Unable to load testimonials')

export default function TestimonialsList({
  request: initialRequest,
  defaultSelected,
}: {
  request: Request
  defaultSelected: string | null
}): JSX.Element {
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

  const scrollToTopRef = useScrollToTop<HTMLDivElement>(request.query.page)

  return (
    <ResultsZone isFetching={isFetching}>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
      >
        {resolvedData ? (
          <>
            <div className="testimonials" ref={scrollToTopRef}>
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
