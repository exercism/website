import React from 'react'
import { RealtimeFeedbackModalProps } from '../../RealTimeFeedbackModal'
import { ContinueButton } from '../../components/FeedbackContentButtons'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function NoImmediateFeedback({
  track,
  onContinue,
  onSendMentoringRequest,
}: Pick<RealtimeFeedbackModalProps, 'track'> &
  Record<'onContinue' | 'onSendMentoringRequest', () => void>): JSX.Element {
  const { t } = useAppTranslation(
    'components/modals/realtime-feedback-modal/feedback-content/no-automated-feedback'
  )
  return (
    <div className="flex flex-col items-start">
      <h3 className="text-h4 mb-12">{t('index.noImmediateFeedback')}</h3>

      <p className="text-16 leading-150 font-medium text-textColor1 mb-8">
        {t('index.ourSystemsDontHave')}
      </p>

      <p className="text-16 mb-16 leading-150">
        {t('index.weRecommendRequesting', { trackTitle: track.title })}
      </p>
      <div className="flex gap-12">
        <button onClick={onSendMentoringRequest} className="btn-primary btn-s">
          {t('index.requestCodeReview')}
        </button>
        <ContinueButton onClick={onContinue} className="btn-secondary" />
      </div>
    </div>
  )
}
