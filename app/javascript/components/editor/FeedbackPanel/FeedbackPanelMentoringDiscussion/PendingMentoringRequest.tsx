// i18n-key-prefix: feedbackPanelMentoringDiscussion.pendingMentoringRequest
// i18n-namespace: components/editor/FeedbackPanel
import React from 'react'
import { FeedbackPanelProps } from '../FeedbackPanel'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function PendingMentoringRequest({
  mentoringRequestLink,
}: Pick<FeedbackPanelProps, 'mentoringRequestLink'>): JSX.Element {
  const { t } = useAppTranslation('components/editor/FeedbackPanel')

  return (
    <div className="flex flex-col">
      <p className="text-p-base mb-8">
        <strong className="font-semibold text-textColor2">
          {t(
            'feedbackPanelMentoringDiscussion.pendingMentoringRequest.youveSubmittedSolution'
          )}
        </strong>{' '}
        {t(
          'feedbackPanelMentoringDiscussion.pendingMentoringRequest.mentorWillProvideFeedback'
        )}
      </p>
      <a className="btn-enhanced btn-s mr-auto" href={mentoringRequestLink}>
        {t(
          'feedbackPanelMentoringDiscussion.pendingMentoringRequest.viewYourRequest'
        )}
      </a>
    </div>
  )
}
