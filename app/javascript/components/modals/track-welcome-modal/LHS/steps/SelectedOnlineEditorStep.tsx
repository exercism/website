import React, { useContext } from 'react'
import { StepButton } from './components/StepButton'
import { TrackContext } from '../../TrackWelcomeModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function SelectedOnlineEdiorStep({
  onContinueToOnlineEditor,
}: Record<'onContinueToOnlineEditor', () => void>): JSX.Element {
  const { send } = useContext(TrackContext)
  const { t } = useAppTranslation(
    'components/modals/track-welcome-modal/LHS/steps'
  )

  return (
    <>
      <h3 className="text-h3 mb-8">
        {t('selectedOnlineEditorStep.youreAllSet')}
      </h3>
      <p className="mb-16">
        {t('selectedOnlineEditorStep.changeMindInstructions')}
      </p>
      <p className="mb-16">
        {t('selectedOnlineEditorStep.letsJumpIntoFirstExercise')}
      </p>

      <div className="flex gap-8">
        <StepButton
          onClick={onContinueToOnlineEditor}
          className="btn-primary flex-grow"
        >
          {t('selectedOnlineEditorStep.continueToOnlineEditor')}
        </StepButton>
        <StepButton
          onClick={() => send('RESET')}
          className="btn-secondary w-1-3"
        >
          {t('selectedOnlineEditorStep.resetChoices')}
        </StepButton>
      </div>
    </>
  )
}
