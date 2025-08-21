import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'
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
  const { t } = useAppTranslation('components/modals/TestimonialModal.tsx')

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
          <Trans
            ns="components/modals/TestimonialModal.tsx"
            i18nKey="byLine"
            values={{ handle: testimonial.student.handle }}
            components={[
              <strong />,
              <HandleWithFlair
                handle={testimonial.student.handle}
                flair={testimonial.student.flair}
                size="large"
              />,
            ]}
          />
        </div>

        <div className="exercise">
          <Trans
            ns="components/modals/TestimonialModal.tsx"
            i18nKey="exerciseLine"
            values={{
              exercise: testimonial.exercise.title,
              track: testimonial.track.title,
            }}
            components={{
              strong: <strong />,
              trackIcon: (
                <TrackIcon
                  iconUrl={testimonial.track.iconUrl}
                  title={testimonial.track.title}
                />
              ),
              trackTitle: <div className="track-title" />,
            }}
          />
        </div>

        <time dateTime={testimonial.createdAt}>
          {fromNow(testimonial.createdAt)}
        </time>
      </div>

      <SharePanel
        title={t('sharePanel.title')}
        url={testimonial.links.self}
        shareTitle={t('sharePanel.shareTitle')}
        platforms={platforms}
      />
    </Modal>
  )
}
