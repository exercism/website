import React from 'react'
import { TrackProgress } from '../../../types'
import { GraphicalIcon, TrackIcon } from '../../../../common'
import { TrackProgressBar } from './TrackProgressBar'

export const TrackSummaryHeader = ({
  track,
}: {
  track: TrackProgress
}): JSX.Element => {
  return (
    <div className="--summary-inner">
      <TrackIcon iconUrl={track.iconUrl} title={track.title} />
      <h3>{track.title}</h3>
      <TrackProgressBar completion={track.completion} />
      <div className="percentage">{track.completion.toFixed(2)}%</div>
      <GraphicalIcon icon="chevron-right" className="--closed-icon" />
      <GraphicalIcon icon="chevron-down" className="--open-icon" />
    </div>
  )
}
