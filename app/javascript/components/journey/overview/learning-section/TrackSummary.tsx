import React from 'react'
import pluralize from 'pluralize'
import { Trans } from 'react-i18next'
import { timeFormat, fromNow } from '@/utils/time'
import { GraphicalIcon } from '@/components/common'
import ProgressGraph from '@/components/common/ProgressGraph'
import { TrackSummaryHeader } from './track-summary/TrackSummaryHeader'
import { useAppTranslation } from '@/i18n/useAppTranslation'
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
  const { t } = useAppTranslation(
    'components/journey/overview/learning-section'
  )

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
              <Trans
                ns="components/journey/overview/learning-section"
                i18nKey="trackSummary.exercisesCompleted"
                values={{
                  completed: track.numCompletedExercises,
                  total: track.numExercises,
                  percent: track.completion.toFixed(2),
                }}
              />
            </p>
          </div>
        </div>

        <div className="date-area">
          <GraphicalIcon icon="entry" />
          <h4 className="journey-h3">
            {timeFormat(track.startedAt, 'DD MMM YYYY')}
          </h4>
          <h5 className="text-h6">
            <Trans
              ns="components/journey/overview/learning-section"
              i18nKey="trackSummary.joinedTrack"
              values={{ title: track.title }}
            />
          </h5>
          <p>
            <Trans
              ns="components/journey/overview/learning-section"
              i18nKey="trackSummary.startedTrackAgo"
              values={{
                title: track.title,
                since: fromNow(track.startedAt),
              }}
              components={{ strong: <strong /> }}
            />
          </p>
        </div>

        <div className="mentor-history-area">
          <GraphicalIcon icon="mentoring" />
          <h4 className="journey-h3">
            {track.numCompletedMentoringDiscussions}
          </h4>
          <h5 className="text-h6">
            <Trans
              ns="components/journey/overview/learning-section"
              i18nKey="trackSummary.mentoringSessionsCompleted"
              values={{
                count: track.numCompletedMentoringDiscussions,
                label: pluralize(
                  'session',
                  track.numCompletedMentoringDiscussions
                ),
              }}
            />
          </h5>
          <p>
            <Trans
              ns="components/journey/overview/learning-section"
              i18nKey="trackSummary.mentoringStatus"
              values={{
                inProgress:
                  track.numInProgressMentoringDiscussions === 0
                    ? t('trackSummary.none')
                    : `${track.numInProgressMentoringDiscussions} ${pluralize(
                        'discussion',
                        track.numInProgressMentoringDiscussions
                      )}`,
                queued:
                  track.numQueuedMentoringRequests === 0
                    ? t('trackSummary.none')
                    : `${track.numQueuedMentoringRequests} ${pluralize(
                        'solution',
                        track.numQueuedMentoringRequests
                      )}`,
              }}
              components={{
                strong: <strong />,
              }}
            />
          </p>
        </div>

        {track.velocity ? (
          <div className="velocity-area">
            <GraphicalIcon icon="velocity" />
            <div className="journey-h3">{track.velocity}</div>
            <h4>{t('trackSummary.progressionVelocity')}</h4>
            {avgVelocity ? (
              <div className="note">
                <Trans
                  ns="components/journey/overview/learning-section"
                  i18nKey="trackSummary.avgVelocity"
                  values={{ avg: avgVelocity }}
                />
              </div>
            ) : null}
            <div className="info">{t('trackSummary.velocityExplanation')}</div>
          </div>
        ) : null}
      </div>
    </details>
  )
}
