import React from 'react'
import { fromNow } from '../../../utils/time'
import { GraphicalIcon, TrackIcon } from '../../common'
import { Testimonial } from '../../types'

export const UnrevealedTestimonial = ({
  track,
  createdAt,
}: Testimonial): JSX.Element => {
  return (
    <div className="testimonial unrevealed">
      <TrackIcon {...track} />
      <GraphicalIcon icon="avatar-placeholder" className="c-avatar" />
      <div className="info">
        <div className="student">Someone left you a testimonial… 😲</div>
        <div className="exercise">Click / tap to reveal</div>
      </div>
      <time dateTime={createdAt}>{fromNow(createdAt)}</time>
      <GraphicalIcon icon="modal" className="action-icon" />
    </div>
  )
}
