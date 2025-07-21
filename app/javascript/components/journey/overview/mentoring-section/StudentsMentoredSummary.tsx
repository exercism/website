// i18n-key-prefix: studentsMentoredSummary
// i18n-namespace: components/journey/overview/mentoring-section
import React from 'react'
import { MentoredTrackProgressList } from '../../types'
import { CommunityRank } from './CommunityRank'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const StudentsMentoredSummary = ({
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
      <div className="journey-h3">{tracks.totals.students}</div>
      <div className="journey-label">
        {t('studentsMentoredSummary.totalStudentsMentored')}
      </div>
      {rank ? <CommunityRank rank={rank} /> : null}
    </div>
  )
}
