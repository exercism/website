import React, { useState } from 'react'
import { fromNow } from '../../../utils/time'
import { Avatar, GraphicalIcon, TrackIcon } from '../../common'
import { Testimonial } from '../../types'
import { TestimonialModal } from '../../modals/TestimonialModal'

export const RevealedTestimonial = ({
  testimonial,
}: {
  testimonial: Testimonial
}): JSX.Element => {
  const [open, setOpen] = useState(false)

  return (
    <React.Fragment>
      <a href="#" onClick={() => setOpen(true)} className="testimonial">
        <TrackIcon {...testimonial.track} />
        <Avatar
          src={testimonial.student.avatarUrl}
          handle={testimonial.student.handle}
        />
        <div className="info">
          <div className="student">{testimonial.student.handle}</div>
          <div className="exercise">
            on {testimonial.exercise.title} in {testimonial.track.title}
          </div>
        </div>
        <div className="content">{testimonial.content}</div>
        <time dateTime={testimonial.createdAt}>
          {fromNow(testimonial.createdAt)}
        </time>
        <GraphicalIcon icon="modal" className="action-icon" />
      </a>
      <TestimonialModal
        open={open}
        testimonial={testimonial}
        onClose={() => setOpen(false)}
      />
    </React.Fragment>
  )
}
