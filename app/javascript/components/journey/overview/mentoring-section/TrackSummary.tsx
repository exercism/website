import React from 'react'
import { TrackIcon } from '../../../common'
import { MentoredTrackProgress } from '../../types'
import pluralize from 'pluralize'

export const TrackSummary = ({
  track,
}: {
  track: MentoredTrackProgress
}): JSX.Element => {
  return (
    <div className="track">
      <div className="dot t-b-csharp" />
      <TrackIcon iconUrl={track.iconUrl} title={track.title} />
      <div className="details">
        <div className="journey-label">{track.title}</div>
        <div className="journey-h4">
          {track.numDiscussions} {pluralize('session', track.numDiscussions)}
        </div>
      </div>
    </div>
  )
}
