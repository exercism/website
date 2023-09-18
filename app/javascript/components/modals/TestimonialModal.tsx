import React from 'react'
import { SharePlatform, Testimonial } from '../types'
import { Modal, ModalProps } from './Modal'
import { Avatar, HandleWithFlair, TrackIcon } from '../common'
import { fromNow } from '../../utils/time'
import { SharePanel } from '../common/SharePanel'

export const TestimonialModal = ({
  testimonial,
  platforms,
  ...props
}: Omit<ModalProps, 'className'> & {
  testimonial: Testimonial
  platforms: readonly SharePlatform[]
}): JSX.Element => {
  return (
    <Modal
      closeButton={true}
      cover={true}
      celebratory
      className="m-testimonial"
      {...props}
    >
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
              size="large"
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
      <SharePanel
        title="Share your testimonial with the world"
        url={testimonial.links.self}
        shareTitle="View this testimonial on Exercism"
        platforms={platforms}
      />
    </Modal>
  )
}
