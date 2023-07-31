import React, { useState, useCallback } from 'react'
import { useMutation, QueryKey, useQueryCache } from 'react-query'
import { fromNow } from '../../../utils/time'
import { GraphicalIcon, TrackIcon } from '../../common'
import { SharePlatform, Testimonial } from '../../types'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { PaginatedResult } from '../TestimonialsList'
import { FetchingBoundary } from '../../FetchingBoundary'
import { TestimonialModal } from '../../modals/TestimonialModal'
import { useIsMounted } from 'use-is-mounted'

const DEFAULT_ERROR = new Error('Unable to reveal testimonial')

export const UnrevealedTestimonial = ({
  testimonial,
  onRevealed,
  cacheKey,
  platforms,
}: {
  testimonial: Testimonial
  onRevealed: () => void
  cacheKey: QueryKey
  platforms: readonly SharePlatform[]
}): JSX.Element => {
  const queryCache = useQueryCache()
  const isMountedRef = useIsMounted()
  const [open, setOpen] = useState(false)
  const [revealedTestimonial, setRevealedTestimonial] =
    useState<Testimonial | null>(null)
  const [reveal, { status, error }] = useMutation<Testimonial>(
    () => {
      const { fetch } = sendRequest({
        endpoint: testimonial.links.reveal,
        method: 'PATCH',
        body: null,
      })

      return fetch.then((json) => typecheck<Testimonial>(json, 'testimonial'))
    },
    {
      onSuccess: (testimonial) => {
        if (!isMountedRef.current) {
          return
        }

        setRevealedTestimonial(testimonial)
        setOpen(true)
      },
    }
  )
  const updateCache = useCallback(() => {
    const oldData = queryCache.getQueryData<PaginatedResult>(cacheKey)

    if (!oldData || !revealedTestimonial) {
      return
    }

    queryCache.setQueryData(cacheKey, {
      ...oldData,
      results: oldData.results.map((oldTestimonial) => {
        return oldTestimonial.uuid === revealedTestimonial.uuid
          ? revealedTestimonial
          : oldTestimonial
      }),
    })
  }, [cacheKey, revealedTestimonial, queryCache])

  return (
    <a
      href="#"
      onClick={(e) => {
        reveal()
        e.preventDefault()
      }}
      className="unrevealed-testimonial"
    >
      <TrackIcon {...testimonial.track} />
      <GraphicalIcon icon="avatar-placeholder" className="c-avatar" />
      <div className="info">
        <div className="student">Someone left you a testimonial… 😲</div>
        <div className="exercise">Click / tap to reveal</div>
      </div>
      <time dateTime={testimonial.createdAt}>
        {fromNow(testimonial.createdAt)}
      </time>
      <GraphicalIcon icon="modal" className="action-icon" />
      <FetchingBoundary
        error={error}
        status={status}
        defaultError={DEFAULT_ERROR}
      />
      {revealedTestimonial ? (
        <TestimonialModal
          open={open}
          testimonial={revealedTestimonial}
          onClose={() => {
            setOpen(false)
            updateCache()
            onRevealed()
          }}
          platforms={platforms}
        />
      ) : null}
    </a>
  )
}
