import React from 'react'
import { ContinueButton } from '../../components/FeedbackContentButtons'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function InProgressMentoring({
  onContinue,
  mentorDiscussionLink,
}: {
  mentorDiscussionLink: string
  onContinue: () => void
}): JSX.Element {
  const { t } = useAppTranslation(
    'components/modals/realtime-feedback-modal/feedback-content/no-automated-feedback'
  )
  return (
    <div className="flex flex-col items-start">
      <h3 className="text-h4 mb-8">{t('index.youHaveMentoringSession')}</h3>
      <p className="text-p-base mb-12">{t('index.itIsGenerallyGood')}</p>

      <div className="flex gap-12">
        <a className="btn-primary btn-s mr-auto" href={mentorDiscussionLink}>
          {t('index.goToYourDiscussion')}
        </a>
        <ContinueButton
          text={t('index.continueToExercise')}
          onClick={onContinue}
          className="btn-secondary"
        />
      </div>
    </div>
  )
}
