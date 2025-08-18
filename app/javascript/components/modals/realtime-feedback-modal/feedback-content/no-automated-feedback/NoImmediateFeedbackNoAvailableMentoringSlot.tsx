import React from 'react'
import { ContinueButton } from '../../components/FeedbackContentButtons'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function NoImmediateFeedbackNoAvailableMentoringSlot({
  onContinue,
}: Record<'onContinue', () => void>): JSX.Element {
  const { t } = useAppTranslation(
    'components/modals/realtime-feedback-modal/feedback-content/no-automated-feedback'
  )
  return (
    <div className="flex flex-col items-start self-stretch">
      <h3 className="text-h4 mb-12">{t('index.noImmediateFeedbackNoSlot')}</h3>

      <p className="text-16 leading-150 font-medium text-textColor1 mb-auto">
        {t('index.ourSystemsDontHave')}
      </p>

      <ContinueButton onClick={onContinue} />
    </div>
  )
}
