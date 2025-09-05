// i18n-key-prefix: track
// i18n-namespace: components/student/tracks-list
import React from 'react'
import { TrackIcon } from '@/components/common/TrackIcon'
import { Icon } from '@/components/common/Icon'
import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import { ProgressBar } from './ProgressBar'
import { fromNow } from '@/utils/time'
import { StudentTrack } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const Track = ({ track }: { track: StudentTrack }): JSX.Element => {
  const { t } = useAppTranslation()

  return (
    <a className="--track e-hover-grow" href={track.webUrl}>
      <TrackIcon
        iconUrl={track.iconUrl}
        title={track.title}
        className="hidden lg:block"
      />
      <div className="--info">
        <div className="--heading">
          <TrackIcon
            iconUrl={track.iconUrl}
            title={track.title}
            className="block lg:hidden"
          />
          <h3 className="--title">{track.title}</h3>
          {!track.isJoined && (
            <div className="items-center hidden md:flex">
              {track.course ? (
                <div className="--v3">{t('track.learningMode')}</div>
              ) : track.isNew ? (
                <div className="--new">
                  <Icon icon="stars" alt={t('track.thisTrackIsNew')} />
                  {t('track.new')}
                </div>
              ) : null}
            </div>
          )}
          {track.hasNotifications && <div className="c-notification-dot" />}
          {track.isJoined && (
            <div className="--joined">
              <GraphicalIcon icon="checkmark" className="lg:mr-8" />
              <span className="hidden lg:block">{t('track.joined')}</span>
            </div>
          )}
        </div>
        <ul className="--counts">
          <li>
            <Icon icon="exercises" alt="Number of exercises" />
            {track.numCompletedExercises == undefined
              ? null
              : `${track.numCompletedExercises}/`}
            {t('track.numberOfExercises', { count: track.numExercises })}
          </li>

          {track.course && (
            <li>
              <Icon icon="concepts" alt="Number of concepts" />
              {track.numCompletedConcepts == undefined
                ? null
                : `${track.numCompletedConcepts}/`}
              {t('track.numberOfConcepts', { count: track.numConcepts })}
            </li>
          )}
        </ul>

        {track.isJoined && (
          <ProgressBar
            numExercises={track.numExercises}
            numCompletedExercises={track.numCompletedExercises}
          />
        )}

        {track.isJoined ? null : (
          <ul className="--tags">
            {track.tags.slice(0, 3).map((tag) => {
              return <li key={tag}>{tag}</li>
            })}
          </ul>
        )}

        {track.isJoined && (
          <div className="--last-touched">
            {t('track.lastTouched', { time: fromNow(track.lastTouchedAt) })}
          </div>
        )}
      </div>
    </a>
  )
}
