import React, { useState, useEffect } from 'react'
import { fromNow } from '../../../utils/time'
import { Avatar, GraphicalIcon, TrackIcon } from '../../common'
import { TestimonialModal } from '../../modals/TestimonialModal'
import { Testimonial } from '../../types'

export const RevealedTestimonial = ({
  testimonial,
  isRevealed,
}: {
  testimonial: Testimonial
  isRevealed: boolean
}): JSX.Element => {
  const [open, setOpen] = useState(false)

  useEffect(() => {
    if (!isRevealed) {
      return
    }

    setOpen(true)
  }, [isRevealed])

  {
    /* TODO: Set testimonial URL */
  }
  return (
    <React.Fragment>
      <a
        href="#"
        onClick={(e) => {
          setOpen(true)
          e.preventDefault()
        }}
        className="testimonial"
      >
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
        {isRevealed ? <div className="new">New</div> : null}
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
