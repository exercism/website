// i18n-key-prefix: sessionsMentoredSummary
// i18n-namespace: components/journey/overview/mentoring-section
import React from 'react'
import { MentoredTrackProgressList } from '../../types'
import { CommunityRank } from './CommunityRank'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const SessionsMentoredSummary = ({
  tracks,
  rank,
}: {
  tracks: MentoredTrackProgressList
  rank?: number
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/journey/overview/mentoring-section'
  )

  return (
    <div className="box">
      <div className="journey-h3">{tracks.totals.discussions}</div>
      <div className="journey-label">
        {t('sessionsMentoredSummary.totalSessionsMentored')}
      </div>
      {rank ? <CommunityRank rank={rank} /> : null}
    </div>
  )
}
