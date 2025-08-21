import React from 'react'
import { fromNow } from '@/utils/date'
import { Testimonial as TestimonialProps } from '@/components/types'
import { Avatar, TrackIcon } from '@/components/common'
import { TestimonialModal } from './TestimonialModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

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
  const { t } = useAppTranslation('components/profile/testimonials-list')

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
          <Trans
            i18nKey="exerciseTrack"
            ns="components/profile/testimonials-list"
            values={{
              exerciseTitle: testimonial.exercise.title,
              trackTitle: testimonial.track.title,
            }}
            components={[
              <strong />,
              <TrackIcon
                iconUrl={testimonial.track.iconUrl}
                title={testimonial.track.title}
              />,
              <div className="track-title">{testimonial.track.title}</div>,
            ]}
          />
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
