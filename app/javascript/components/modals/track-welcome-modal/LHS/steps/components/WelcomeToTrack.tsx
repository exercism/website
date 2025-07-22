// i18n-key-prefix: welcomeToTrack
// i18n-namespace: components/modals/track-welcome-modal/LHS/steps/components
import React, { useContext } from 'react'
import { TrackContext } from '../../../TrackWelcomeModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'
export function WelcomeToTrack(): JSX.Element {
  const { track } = useContext(TrackContext)
  const { t } = useAppTranslation(
    'components/modals/track-welcome-modal/LHS/steps/components'
  )
  return (
    <h1 className="text-h1 mb-8">
      {t('welcomeToTrack.welcomeTo', { trackTitle: track.title })}
    </h1>
  )
}
