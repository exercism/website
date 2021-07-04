import React from 'react'
import { TrackProgressList } from '../../types'

export const TracksEnrolledSummary = ({
  tracks,
}: {
  tracks: TrackProgressList
}): JSX.Element => {
  return (
    <div className="box">
      <div className="journey-h3">{tracks.length}</div>
      <div className="journey-label">Tracks enrolled</div>
    </div>
  )
}
