import React from 'react'
import { fromNow } from '@/utils/date'
import { Testimonial as TestimonialProps } from '@/components/types'
import { Avatar, GraphicalIcon, TrackIcon } from '@/components/common'
import { TestimonialModal } from '@/components/profile/testimonials-list/TestimonialModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const ImpactTestimonial = ({
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
  const { t } = useAppTranslation('components/impact/ImpactTestimonial.tsx')
  return (
    <React.Fragment>
      <button className="testimonial" type="button" onClick={onClick}>
        <div className="absolute flex gap-8 items-center -top-24">
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
        <div className="content">{testimonial.content}</div>
        <div className="inline-flex flex-wrap items-center gap-x-4 text-16 text-textColor2 leading-160">
          <span className="font-medium">{testimonial.student.handle}</span>{' '}
          {t('impactTestimonial.saidThisAbout')}{' '}
          <span className="font-medium">{testimonial.mentor.handle}</span>
        </div>
        <div className="exercise">
          {testimonial.exercise.title} {t('impactTestimonial.on')}{' '}
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

export default ImpactTestimonial
