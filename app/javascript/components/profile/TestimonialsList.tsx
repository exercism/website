import React, { useState, useCallback } from 'react'
import { Request, usePaginatedRequestQuery } from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import { Testimonial as TestimonialProps } from '../types'
import { Testimonial } from './testimonials-list/Testimonial'

const DEFAULT_ERROR = new Error('Unable to load testimonials')

export const TestimonialsList = ({
  request,
  defaultSelected,
}: {
  request: Request
  defaultSelected: string | null
}): JSX.Element => {
  const [selected, setSelected] = useState<string | null>(defaultSelected)
  const { resolvedData, isFetching, status, error } = usePaginatedRequestQuery<{
    testimonials: readonly TestimonialProps[]
  }>(request.endpoint, request)

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
          <div className="testimonials">
            {resolvedData.testimonials.map((t) => {
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
        ) : null}
      </FetchingBoundary>
    </ResultsZone>
  )
}
