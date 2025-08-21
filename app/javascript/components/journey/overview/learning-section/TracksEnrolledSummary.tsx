import React from 'react'
import { TrackProgressList } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const TracksEnrolledSummary = ({
  tracks,
}: {
  tracks: TrackProgressList
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/journey/overview/learning-section'
  )

  return (
    <div className="box">
      <div className="journey-h3">{tracks.length}</div>
      <div className="journey-label">
        {t(
          tracks.length > 1
            ? 'tracksEnrolledSummary.tracksEnrolled'
            : 'tracksEnrolledSummary.tracksEnrolled'
        )}{' '}
        enrolled
      </div>
    </div>
  )
}
