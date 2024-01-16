import React from 'react'
import pluralize from 'pluralize'
import { timeFormat, fromNow } from '@/utils/time'
import { GraphicalIcon } from '@/components/common'
import ProgressGraph from '@/components/common/ProgressGraph'
import { TrackSummaryHeader } from './track-summary/TrackSummaryHeader'
import type { TrackProgress } from '../../types'

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
          <h4 className="journey-h3">
            {timeFormat(track.startedAt, 'DD MMM YYYY')}
          </h4>
          <h5 className="text-h6">When you joined the {track.title} Track</h5>
          <p>
            You started working through the {track.title} Track{' '}
            <strong>{fromNow(track.startedAt)}</strong>.
          </p>
        </div>
        <div className="mentor-history-area">
          <GraphicalIcon icon="mentoring" />
          <h4 className="journey-h3">
            {track.numCompletedMentoringDiscussions}
          </h4>
          <h5 className="text-h6">
            Mentoring{' '}
            {pluralize('session', track.numCompletedMentoringDiscussions)}{' '}
            completed
          </h5>

          <p>
            You have{' '}
            <strong>
              {track.numInProgressMentoringDiscussions === 0
                ? 'none'
                : `${track.numInProgressMentoringDiscussions} ${pluralize(
                    'discussion',
                    track.numInProgressMentoringDiscussions
                  )}`}
            </strong>{' '}
            in progress and{' '}
            <strong>
              {track.numQueuedMentoringRequests === 0
                ? 'none'
                : `${track.numQueuedMentoringRequests} ${pluralize(
                    'solution',
                    track.numQueuedMentoringRequests
                  )}`}
            </strong>{' '}
            in the queue.
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
              This is a measure of how quickly you&apos;ve progressed through
              the track in the last 6 months
            </div>
          </div>
        ) : null}
      </div>
    </details>
  )
}
