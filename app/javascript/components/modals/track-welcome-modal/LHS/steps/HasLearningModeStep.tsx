import React, { useContext } from 'react'
import { TrackContext } from '../../TrackWelcomeModal'
import { StepButton } from './components/StepButton'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function HasLearningModeStep({
  onSelectLearningMode,
  onSelectPracticeMode,
}: Record<
  'onSelectLearningMode' | 'onSelectPracticeMode',
  () => void
>): JSX.Element {
  const { track } = useContext(TrackContext)
  const { t } = useAppTranslation(
    'components/modals/track-welcome-modal/LHS/steps'
  )

  return (
    <>
      <h3 className="text-h3 mb-8">
        {t('hasLearningModeStep.hereToLearnOrPractice')}
      </h3>
      <p data-capy-element="welcome-modal-track-info" className="mb-12">
        {t('hasLearningModeStep.trackCanBeUsedForLearningOrPracticing', {
          trackTitle: track.title,
        })}
      </p>
      <p className="mb-12">
        {t('hasLearningModeStep.recommendLearningModeIfNew', {
          trackTitle: track.title,
        })}
      </p>
      <p className="mb-16">
        <span className="font-semibold">
          {t('hasLearningModeStep.startTrackInLearningOrPracticeMode', {
            trackTitle: track.title,
          })}
        </span>{' '}
        (You can always change later.)
      </p>

      <div className="grid grid-cols-2 gap-12 items-center">
        <StepButton onClick={onSelectLearningMode} className="btn-primary">
          {t('hasLearningModeStep.learningMode')}
        </StepButton>
        <StepButton onClick={onSelectPracticeMode} className="btn-secondary">
          {t('hasLearningModeStep.practiceMode')}
        </StepButton>
      </div>
    </>
  )
}
