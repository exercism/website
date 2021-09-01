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
        <div className="date-area">
          <GraphicalIcon icon="entry" />
          {/* TODO use started_at */}
          <h4 className="journey-h3">5th June 2021</h4>
          <p className="text-h6">When you joined the {track.title} Track</p>
          <p>
            You've been working through this the {track.title} Track for{' '}
            <strong>9 months</strong>.
          </p>
        </div>
        <div className="mentor-history-area">
          <GraphicalIcon icon="mentoring" />
          {/* TODO num_completed_mentoring_discussions */}
          <h4 className="journey-h3">42</h4>
          <p className="text-h6">Mentoring sessions completed</p>

          {/* TODO: num_in_progress_mentoring_discussions */}
          {/* TODO: num_queued_mentoring_requests */}
          {/* TODO: If zero say "none" (e.g. You have none in progress and none in the queue)*/}
          <p>
            You have <strong>9 discussions</strong> in progress and{' '}
            <strong>3 solutions</strong> in the queue.
          </p>
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
