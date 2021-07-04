import React from 'react'
import { MentoredTrackProgressList } from '../../types'
import { CommunityRank } from './CommunityRank'

export const SessionsMentoredSummary = ({
  tracks,
  rank,
}: {
  tracks: MentoredTrackProgressList
  rank?: number
}): JSX.Element => {
  return (
    <div className="box">
      <div className="journey-h3">{tracks.totals.discussions}</div>
      <div className="journey-label">Total sessions mentored</div>
      {rank ? <CommunityRank rank={rank} /> : null}
    </div>
  )
}
