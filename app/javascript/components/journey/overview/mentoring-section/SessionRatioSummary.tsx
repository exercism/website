import React from 'react'
import { MentoredTrackProgressList } from '../../types'
import { CommunityRank } from './CommunityRank'

export const SessionRatioSummary = ({
  tracks,
}: {
  tracks: MentoredTrackProgressList
}): JSX.Element => {
  return (
    <div className="box">
      <div className="journey-h3">{tracks.sessionRatio.toFixed(2)}</div>
      <div className="journey-label">Sessions per student</div>
    </div>
  )
}
