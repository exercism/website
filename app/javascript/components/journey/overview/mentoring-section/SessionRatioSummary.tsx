// i18n-key-prefix: sessionRatioSummary
// i18n-namespace: components/journey/overview/mentoring-section
import React from 'react'
import { MentoredTrackProgressList } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const SessionRatioSummary = ({
  tracks,
}: {
  tracks: MentoredTrackProgressList
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/journey/overview/mentoring-section'
  )
  return (
    <div className="box">
      <div className="journey-h3">{tracks.sessionRatio.toFixed(2)}</div>
      <div className="journey-label">
        {t('sessionRatioSummary.sessionsPerStudent')}
      </div>
    </div>
  )
}
