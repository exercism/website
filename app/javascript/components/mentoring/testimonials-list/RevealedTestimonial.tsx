import React, { useState } from 'react'
import { QueryKey } from '@tanstack/react-query'
import { fromNow } from '@/utils/date'
import { Avatar, GraphicalIcon, HandleWithFlair, TrackIcon } from '../../common'
import { TestimonialModal } from '../../modals/TestimonialModal'
import { Testimonial, SharePlatform } from '../../types'
import { OptionsDropdown } from './revealed-testimonial/OptionsDropdown'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const RevealedTestimonial = ({
  testimonial,
  cacheKey,
  isRevealed,
  platforms,
}: {
  testimonial: Testimonial
  cacheKey: QueryKey
  isRevealed: boolean
  platforms: readonly SharePlatform[]
}): JSX.Element => {
  const [open, setOpen] = useState(false)
  const { t } = useAppTranslation()

  return (
    <React.Fragment>
      <div className="testimonial">
        <a
          href="#"
          onClick={(e) => {
            setOpen(true)
            e.preventDefault()
          }}
        >
          <TrackIcon {...testimonial.track} />
          <Avatar
            src={testimonial.student.avatarUrl}
            handle={testimonial.student.handle}
          />
          <div className="info">
            <div className="student">
              <HandleWithFlair
                handle={testimonial.student.handle}
                flair={testimonial.student.flair}
              />
            </div>
            <div className="exercise">
              {t('revealedTestimonial.onExerciseInTrack', {
                exerciseTitle: testimonial.exercise.title,
                trackTitle: testimonial.track.title,
              })}
            </div>
          </div>
          {isRevealed ? (
            <div className="new">{t('revealedTestimonial.new')}</div>
          ) : null}
          <div className="content">{testimonial.content}</div>
          <time dateTime={testimonial.createdAt}>
            {fromNow(testimonial.createdAt)}
          </time>
          <GraphicalIcon icon="modal" className="action-icon" />
        </a>
        <OptionsDropdown testimonial={testimonial} cacheKey={cacheKey} />
      </div>
      <TestimonialModal
        open={open}
        testimonial={testimonial}
        onClose={() => setOpen(false)}
        platforms={platforms}
      />
    </React.Fragment>
  )
}
