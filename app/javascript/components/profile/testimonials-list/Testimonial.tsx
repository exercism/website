import React from 'react'
import { fromNow } from '@/utils/date'
import { Testimonial as TestimonialProps } from '@/components/types'
import {
  Avatar,
  GraphicalIcon,
  HandleWithFlair,
  TrackIcon,
} from '@/components/common'
import { TestimonialModal } from './TestimonialModal'

export const Testimonial = ({
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
          <HandleWithFlair
            handle={testimonial.student.handle}
            flair={testimonial.student.flair}
            className="font-medium"
          />
          said this about
          <HandleWithFlair
            handle={testimonial.mentor.handle}
            flair={testimonial.mentor.flair}
            className="font-medium"
          />
        </div>
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
