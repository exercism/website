import React from 'react'
import { Testimonial } from '../../types'
import { Modal, ModalProps } from '../../modals/Modal'
import { Avatar, HandleWithFlair, TrackIcon } from '../../common'
import { fromNow } from '../../../utils/time'

export const TestimonialModal = ({
  testimonial,
  ...props
}: Omit<ModalProps, 'className'> & {
  testimonial: Testimonial
}): JSX.Element => {
  return (
    <Modal cover={true} celebratory className="m-testimonial" {...props}>
      <Avatar
        src={testimonial.student.avatarUrl}
        handle={testimonial.student.handle}
      />
      <div className="testimonial-section">
        <div className="content">{testimonial.content}</div>
        <div className="student">
          by&nbsp;
          <strong>
            <HandleWithFlair
              handle={testimonial.student.handle}
              flair={testimonial.student.flair}
              size={16}
            />
          </strong>
        </div>
        <div className="exercise">
          on <strong>{testimonial.exercise.title}</strong> in
          <TrackIcon
            iconUrl={testimonial.track.iconUrl}
            title={testimonial.track.title}
          />
          <div className="track-title">{testimonial.track.title}</div>
        </div>
        <time dateTime={testimonial.createdAt}>
          {fromNow(testimonial.createdAt)}
        </time>
      </div>
    </Modal>
  )
}
