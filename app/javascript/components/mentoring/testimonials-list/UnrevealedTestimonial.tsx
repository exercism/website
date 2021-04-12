import React from 'react'
import { useMutation, queryCache, QueryKey } from 'react-query'
import { fromNow } from '../../../utils/time'
import { GraphicalIcon, TrackIcon } from '../../common'
import { Testimonial } from '../../types'
import { useIsMounted } from 'use-is-mounted'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { PaginatedResult } from '../TestimonialsList'
import { FetchingBoundary } from '../../FetchingBoundary'

const DEFAULT_ERROR = new Error('Unable to reveal testimonial')

export const UnrevealedTestimonial = ({
  testimonial,
  onRevealed,
  cacheKey,
}: {
  testimonial: Testimonial
  onRevealed: () => void
  cacheKey: QueryKey
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [reveal, { status, error }] = useMutation<Testimonial | undefined>(
    () => {
      return sendRequest({
        endpoint: testimonial.links.reveal,
        method: 'PATCH',
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<Testimonial>(json, 'testimonial')
      })
    },
    {
      onSuccess: (testimonial) => {
        const oldData = queryCache.getQueryData<PaginatedResult>(cacheKey)

        if (!oldData || !testimonial) {
          return
        }

        queryCache.setQueryData(cacheKey, {
          ...oldData,
          results: oldData.results.map((oldTestimonial) => {
            return oldTestimonial.id === testimonial.id
              ? testimonial
              : oldTestimonial
          }),
        })

        onRevealed()
      },
    }
  )

  return (
    <React.Fragment>
      <a
        href="#"
        onClick={(e) => {
          reveal()
          e.preventDefault()
        }}
        className="testimonial unrevealed"
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
      </a>
    </React.Fragment>
  )
}
