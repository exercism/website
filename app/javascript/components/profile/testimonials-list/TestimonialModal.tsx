import React from 'react'
import { Testimonial } from '../../types'
import { Modal, ModalProps } from '../../modals/Modal'
import { Avatar, GraphicalIcon, TrackIcon } from '../../common'
import { fromNow } from '../../../utils/time'
import { Trans } from 'react-i18next'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const TestimonialModal = ({
  testimonial,
  ...props
}: Omit<ModalProps, 'className'> & {
  testimonial: Testimonial
}): JSX.Element => {
  const { t } = useAppTranslation('components/profile/testimonials-list')

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
          <Trans
            i18nKey="attribution"
            ns="components/profile/testimonials-list"
            values={{
              student: testimonial.student.handle,
              mentor: testimonial.mentor.handle,
            }}
            components={{
              student: <span className="font-medium" />,
              mentor: <span className="font-medium" />,
            }}
          />
        </div>

        <div className="exercise">
          <Trans
            ns="components/profile/testimonials-list"
            i18nKey="exerciseTrack"
            values={{
              exerciseTitle: testimonial.exercise.title,
              trackTitle: testimonial.track.title,
            }}
            components={{
              0: <strong />,
              1: (
                <TrackIcon
                  iconUrl={testimonial.track.iconUrl}
                  title={testimonial.track.title}
                />
              ),
              2: <div className="track-title" />,
            }}
          />
        </div>

        <time dateTime={testimonial.createdAt}>
          {fromNow(testimonial.createdAt)}
        </time>
      </div>
    </Modal>
  )
}
