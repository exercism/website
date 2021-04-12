import React from 'react'
import { Testimonial } from '../types'
import { Modal, ModalProps } from './Modal'
import {
  Avatar,
  TrackIcon,
  GraphicalIcon,
  CopyToClipboardButton,
} from '../common'
import { fromNow } from '../../utils/time'

export const TestimonialModal = ({
  testimonial,
  ...props
}: Omit<ModalProps, 'className'> & {
  testimonial: Testimonial
}): JSX.Element => {
  return (
    <Modal cover={true} className="m-testimonial" {...props}>
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
        <h3>Share your testimonial with the world</h3>
        {/* TODO: Set link */}
        <div className="btns">
          {/* TODO: https://dev.to/share-to-dev-button */}
          {/* TODO: Set link */}
          <a href="#" className="devto">
            <GraphicalIcon icon="external-site-devto" />
            DEV.to
          </a>
          {/* TODO: Set link */}
          <a href="#" className="linkedin">
            <GraphicalIcon icon="external-site-linkedin" />
            LinkedIn
          </a>
          {/* TODO: Set link */}
          <a href="#" className="reddit">
            <GraphicalIcon icon="external-site-reddit" />
            Reddit
          </a>
          {/* TODO: Set link */}
          <a href="#" className="twitter">
            <GraphicalIcon icon="external-site-twitter" />
            Twitter
          </a>
          {/* TODO: Set link */}
          <a href="#" className="facebook">
            <GraphicalIcon icon="external-site-facebook" />
            Facebook
          </a>
        </div>
        {/* TODO: Set link */}
        <CopyToClipboardButton textToCopy="https://exercism.io/some-url-for-a-publicly-shareable-testimonial" />
      </div>
    </Modal>
  )
}
