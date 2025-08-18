// i18n-key-prefix: deepDiveVideoContent
// i18n-namespace: components/modals/realtime-feedback-modal/feedback-content
import React from 'react'
import YoutubePlayerWithMutation from '@/components/common/YoutubePlayerWithMutation'
import { ContinueButton } from '../components/FeedbackContentButtons'
import type { Props } from '@/components/editor/Props'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type DeepDiveVideoContentProps = {
  exercise: Props['exercise']
  onContinue: () => void
  links: Props['links']
}
export function DeepDiveVideoContent({
  exercise,
  onContinue,
  links,
}: DeepDiveVideoContentProps) {
  const { t } = useAppTranslation(
    'components/modals/realtime-feedback-modal/feedback-content'
  )
  return (
    <>
      <h3 className="text-h3 mb-8">
        {t('deepDiveVideoContent.digDeeperInto', {
          exerciseTitle: exercise.title,
        })}
      </h3>
      <p className="text-p-large mb-16">{exercise.deepDiveBlurb}</p>
      <div className="w-[100%] mb-16">
        <YoutubePlayerWithMutation
          id={exercise.deepDiveYoutubeId}
          markAsSeenEndpoint={links.markVideoAsSeenEndpoint}
        />
      </div>
      <ContinueButton
        text={t('deepDiveVideoContent.continue')}
        onClick={onContinue}
      />
    </>
  )
}
