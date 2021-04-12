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
        {isRevealed ? <span>Revealed</span> : null}
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
