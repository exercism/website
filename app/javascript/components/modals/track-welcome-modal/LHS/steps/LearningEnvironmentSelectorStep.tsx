import React, { useContext } from 'react'
import { TrackContext } from '../../TrackWelcomeModal'
import { StepButton } from './components/StepButton'
import { BootcampRecommendationView } from '../BootcampRecommendationView'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function LearningEnvironmentSelectorStep({
  onSelectLocalMachine,
  onSelectOnlineEditor,
}: Record<
  'onSelectLocalMachine' | 'onSelectOnlineEditor',
  () => void
>): JSX.Element {
  const { track, shouldShowBootcampRecommendationView } =
    useContext(TrackContext)
  const { t } = useAppTranslation(
    'components/modals/track-welcome-modal/LHS/steps'
  )

  if (shouldShowBootcampRecommendationView) {
    return <BootcampRecommendationView />
  }

  return (
    <>
      <h3 className="text-h3 mb-8">
        {t('learningEnvironmentSelectorStep.onlineOrOnYourComputer')}
      </h3>
      <p className="mb-12">
        {t(
          'learningEnvironmentSelectorStep.solveExercisesUsingEditorOrLocally',
          { trackTitle: track.title }
        )}
      </p>
      <p className="mb-12">
        {t('learningEnvironmentSelectorStep.recommendStartingWithEditor')}
      </p>
      <p className="mb-16">
        <span className="font-semibold">
          {t(
            'learningEnvironmentSelectorStep.howWouldYouLikeToStartSolvingExercises',
            { trackTitle: track.title }
          )}
        </span>
      </p>

      <div className="grid grid-cols-2 gap-12 items-center">
        <StepButton onClick={onSelectOnlineEditor} className="btn-primary">
          {t('learningEnvironmentSelectorStep.inTheOnlineEditor')}
        </StepButton>
        <StepButton onClick={onSelectLocalMachine} className="btn-secondary">
          {t('learningEnvironmentSelectorStep.onMyLocalMachine')}
        </StepButton>
      </div>
    </>
  )
}
