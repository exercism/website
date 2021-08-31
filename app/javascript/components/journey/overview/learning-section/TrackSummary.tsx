import React from 'react'
import { TrackSummaryHeader } from './track-summary/TrackSummaryHeader'
import { GraphicalIcon, ProgressGraph } from '../../../common'
import { TrackProgress } from '../../types'

export const TrackSummary = ({
  track,
  expanded,
  avgVelocity,
}: {
  track: TrackProgress
  expanded: boolean
  avgVelocity: number | null
}): JSX.Element => {
  return (
    <details className="c-details track" open={expanded}>
      <summary className="--summary">
        <TrackSummaryHeader track={track} />
      </summary>
      <div className="track-details">
        <div className="time-area">
          <ProgressGraph
            data={track.progressChart.data}
            height={120}
            width={300}
          />
          <div className="info">
            <h4>{track.progressChart.period}</h4>
            <p>
              {track.numCompletedExercises} / {track.numExercises} (
              {track.completion.toFixed(2)}%) exercises completed
            </p>
          </div>
        </div>
        {track.velocity ? (
          <div className="velocity-area">
            <GraphicalIcon icon="velocity" />
            <div className="journey-h3">{track.velocity}</div>
            <h4>Progression Velocity</h4>
            {avgVelocity ? (
              <div className="note">Avg. on Exercism = {avgVelocity}</div>
            ) : null}
            <div className="info">
              This is a measure of how quickly you’ve progressed through the
              track in the last 6 months
            </div>
          </div>
        ) : null}
      </div>
    </details>
  )
}
