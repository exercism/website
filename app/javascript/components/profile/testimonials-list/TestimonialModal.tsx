import React from 'react'
import { Testimonial } from '../../types'
import { Modal, ModalProps } from '../../modals/Modal'
import { Avatar, GraphicalIcon, HandleWithFlair, TrackIcon } from '../../common'
import { fromNow } from '../../../utils/time'

export const TestimonialModal = ({
  testimonial,
  ...props
}: Omit<ModalProps, 'className'> & {
  testimonial: Testimonial
}): JSX.Element => {
  return (
    <Modal cover={true} celebratory className="m-testimonial" {...props}>
      <div className="avatar-group">
        <Avatar
          handle={testimonial.student.handle}
          src={testimonial.student.avatarUrl}
          className="h-[48px] w-[48px]"
        />
        <GraphicalIcon
          icon="arrow-right"
          width={16}
          height={16}
          className="filter-textColor6 -translate-y-[0.5px]"
        />
        <Avatar
          handle={testimonial.mentor.handle}
          src={testimonial.mentor.avatarUrl}
          className="h-[48px] w-[48px]"
        />
      </div>
      <div className="testimonial-section">
        <div className="content">{testimonial.content}</div>
        <div className="inline-flex flex-wrap items-center gap-x-4 text-16 text-textColor2 leading-160">
          <div className="user-name">
            <HandleWithFlair
              handle={testimonial.student.handle}
              flair={testimonial.student.flair}
              className="font-medium"
            />
          </div>
          said this about
          <div className="user-name">
            <HandleWithFlair
              handle={testimonial.mentor.handle}
              flair={testimonial.mentor.flair}
              className="font-medium"
            />
          </div>
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
