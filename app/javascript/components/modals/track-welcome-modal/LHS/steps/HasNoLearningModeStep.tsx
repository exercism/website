import React, { useContext } from 'react'
import { TrackContext } from '../../TrackWelcomeModal'
import { StepButton } from './components/StepButton'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export function HasNoLearningModeStep({
  onContinue,
}: {
  onContinue: () => void
}): JSX.Element {
  const { track, links } = useContext(TrackContext)
  const { t } = useAppTranslation(
    'components/modals/track-welcome-modal/LHS/steps'
  )

  return (
    <>
      <h3 className="text-h3 mb-8">{t('noLearningModeStep.title')}</h3>

      <p className="mb-12">
        <Trans
          ns="components/modals/track-welcome-modal/LHS/steps"
          i18nKey="noLearningModeStep.description"
          values={{
            trackTitle: track.title,
            numExercises: track.numExercises,
          }}
        />
      </p>

      <p className="mb-12">
        <Trans
          t={t}
          ns="components/modals/track-welcome-modal/LHS/steps"
          i18nKey="noLearningModeStep.resources"
          values={{ trackTitle: track.title }}
          components={[
            <a
              className="font-semibold text-prominentLinkColor"
              href={links.learningResources}
              target="_blank"
              rel="noopener noreferrer"
            />,
          ]}
        />
      </p>

      <StepButton onClick={onContinue} className="btn-primary w-fit">
        {t('noLearningModeStep.continue')}
      </StepButton>
    </>
  )
}
