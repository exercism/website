import React from 'react'
import { ContinueButton } from '../../components/FeedbackContentButtons'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function PendingMentoringRequest({
  mentoringRequestLink,
  onContinue,
}: {
  mentoringRequestLink: string
  onContinue: () => void
}): JSX.Element {
  const { t } = useAppTranslation(
    'components/modals/realtime-feedback-modal/feedback-content/no-automated-feedback'
  )
  return (
    <div className="flex flex-col items-start">
      <h3 className="text-h4 mb-12">{t('index.youveSubmittedSolution')}</h3>

      <p className="text-16 mb-16 leading-150">
        {t('index.mentorWillTakeLook')}
      </p>
      <div className="flex gap-12">
        <ContinueButton onClick={onContinue} className="btn-primary" />
        <a className="btn-secondary btn-s mr-auto" href={mentoringRequestLink}>
          {t('index.viewYourRequest')}
        </a>
      </div>
    </div>
  )
}
