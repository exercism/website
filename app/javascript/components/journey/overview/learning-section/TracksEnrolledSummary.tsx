import React from 'react'
import pluralize from 'pluralize'
import { TrackProgressList } from '../../types'

export const TracksEnrolledSummary = ({
  tracks,
}: {
  tracks: TrackProgressList
}): JSX.Element => {
  return (
    <div className="box">
      <div className="journey-h3">{tracks.length}</div>
      <div className="journey-label">
        {pluralize('Track', tracks.length)} enrolled
      </div>
    </div>
  )
}
