import React from 'react'
import { fromNow } from '@/utils/date'
import { Testimonial as TestimonialProps } from '@/components/types'
import { Avatar, TrackIcon } from '@/components/common'
import { TestimonialModal } from './TestimonialModal'

const ProfileTestimonial = ({
  open,
  testimonial,
  onClick,
  onClose,
}: {
  testimonial: TestimonialProps
  open: boolean
  onClick: () => void
  onClose: () => void
}): JSX.Element => {
  return (
    <React.Fragment>
      <button className="testimonial" type="button" onClick={onClick}>
        <Avatar
          handle={testimonial.student.handle}
          src={testimonial.student.avatarUrl}
          className="h-[48px] w-[48px]"
        />
        <div className="content">{testimonial.content}</div>
        <span className="student-name">{testimonial.student.handle}</span>
        <div className="exercise">
          {testimonial.exercise.title} on{' '}
          <TrackIcon
            iconUrl={testimonial.track.iconUrl}
            title={testimonial.track.title}
          />
          <div className="track-title">{testimonial.track.title}</div>
        </div>
        <time dateTime={testimonial.createdAt}>
          {fromNow(testimonial.createdAt)}
        </time>
      </button>
      <TestimonialModal
        testimonial={testimonial}
        open={open}
        onClose={onClose}
      />
    </React.Fragment>
  )
}

export default ProfileTestimonial
