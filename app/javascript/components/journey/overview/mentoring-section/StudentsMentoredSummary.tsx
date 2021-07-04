import React from 'react'
import { MentoredTrackProgressList } from '../../types'
import { CommunityRank } from './CommunityRank'

export const StudentsMentoredSummary = ({
  tracks,
  rank,
}: {
  tracks: MentoredTrackProgressList
  rank?: number
}): JSX.Element => {
  return (
    <div className="box">
      <div className="journey-h3">{tracks.totals.students}</div>
      <div className="journey-label">Total students mentored</div>
      {rank ? <CommunityRank rank={rank} /> : null}
    </div>
  )
}
