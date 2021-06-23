import React from 'react'
import { MentoredTrackProgressList } from '../../../types'
import { CommunityRank } from './CommunityRank'

export const SessionRatioSummary = ({
  tracks,
  rank,
}: {
  tracks: MentoredTrackProgressList
  rank?: number
}): JSX.Element => {
  return (
    <div className="box">
      <div className="journey-h3">{tracks.sessionRatio.toFixed(2)}</div>
      <div className="journey-label">Sessions per student</div>
      {rank ? <CommunityRank rank={rank} /> : null}
    </div>
  )
}
