import React, { useContext, useEffect } from 'react'
import { TrackContext } from '../../TrackWelcomeModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function OpenModalStep({
  onHasLearningMode,
  onHasNoLearningMode,
}: Record<
  'onHasLearningMode' | 'onHasNoLearningMode',
  () => void
>): JSX.Element {
  const { track } = useContext(TrackContext)
  const { t } = useAppTranslation()

  useEffect(() => {
    if (track.course) {
      onHasLearningMode()
    } else onHasNoLearningMode()
  }, [onHasLearningMode, onHasNoLearningMode, track])

  return <div>{t('openModalStep.loading')}</div>
}
