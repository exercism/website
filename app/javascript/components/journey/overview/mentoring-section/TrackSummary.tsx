// i18n-key-prefix: trackSummary
// i18n-namespace: components/journey/overview/mentoring-section
import React from 'react'
import { TrackIcon } from '../../../common'
import { MentoredTrackProgress } from '../../types'
import pluralize from 'pluralize'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const TrackSummary = ({
  track,
}: {
  track: MentoredTrackProgress
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/journey/overview/mentoring-section'
  )

  return (
    <div className="track">
      <div className="dot t-b-csharp" />
      <TrackIcon iconUrl={track.iconUrl} title={track.title} />
      <div className="details">
        <div className="journey-label">{track.title}</div>
        <div className="journey-h4">
          {t('trackSummary.session', { count: track.numDiscussions })}
        </div>
      </div>
    </div>
  )
}
