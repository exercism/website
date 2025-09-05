import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { MedianWaitTime } from '@/components/common/MedianWaitTime'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import { FormButton } from '@/components/common/FormButton'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { useMentoringRequest } from './MentoringRequestFormComponents'
import type {
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
  MentorSessionRequest as Request,
} from '@/components/types'
import {
  TrackObjectivesTextArea,
  SolutionCommentTextArea,
} from './MentoringRequestFormComponents'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

const DEFAULT_ERROR = new Error('Unable to create mentor request')

export const MentoringRequestForm = ({
  trackObjectives,
  track,
  exercise,
  links,
  onSuccess,
}: {
  trackObjectives: string
  track: Track
  exercise: Exercise
  links: DiscussionLinks
  onSuccess: (mentorRequest: Request) => void
}): JSX.Element => {
  const { t } = useAppTranslation()
  const {
    error,
    handleSubmit,
    solutionCommentRef,
    status,
    trackObjectivesRef,
  } = useMentoringRequest(links, onSuccess)

  return (
    <div className="mentoring-request-section">
      <div className="direct">
        <h3>
          {t('mentoringRequestForm.sendThisLinkFriend')}.{' '}
          <a href={links.learnMoreAboutPrivateMentoring}>
            {t('mentoringRequestForm.learnMore')}
          </a>
        </h3>
        <CopyToClipboardButton textToCopy={links.privateMentoring} />
      </div>
      <form
        data-turbo="false"
        className="c-mentoring-request-form"
        onSubmit={handleSubmit}
      >
        <div className="heading">
          <div className="info">
            <h2>{t('mentoringRequestForm.itsTimeToDeepen')}</h2>
            <p>
              <Trans
                i18nKey="mentoringRequestForm.startMentoringDiscussion"
                ns="components/student/mentoring-session/mentoring-request"
                values={{ exerciseTitle: exercise.title }}
                components={{ strong: <strong /> }}
              />
            </p>
          </div>
          <GraphicalIcon icon="mentoring" category="graphics" />
        </div>
        <TrackObjectivesTextArea
          defaultValue={trackObjectives}
          track={track}
          ref={trackObjectivesRef}
        />
        <SolutionCommentTextArea ref={solutionCommentRef} />
        <FormButton status={status} className="btn-primary btn-m">
          {t('mentoringRequestForm.submitMentoringRequest')}
        </FormButton>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        />
        <p className="flow-explanation">
          {t('mentoringRequestForm.openForMentor')}
          <MedianWaitTime seconds={track.medianWaitTime} />
        </p>
      </form>
    </div>
  )
}
