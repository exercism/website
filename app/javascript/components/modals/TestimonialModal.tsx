import React from 'react'
import { Testimonial } from '../types'
import { Modal, ModalProps } from './Modal'
import { Avatar, TrackIcon } from '../common'
import { fromNow } from '../../utils/time'
import { SharePanel } from '../common/SharePanel'

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
          by <strong>{testimonial.student.handle}</strong>
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
      <div className="share-section">
        <SharePanel
          title="Share your testimonial with the world"
          textToCopy="https://exercism.io/some-url-for-a-publicly-shareable-testimonial"
        />
      </div>
    </Modal>
  )
}
