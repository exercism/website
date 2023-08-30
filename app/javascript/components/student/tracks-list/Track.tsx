import React from 'react'
import pluralize from 'pluralize'
import { TrackIcon } from '@/components/common/TrackIcon'
import { Icon } from '@/components/common/Icon'
import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import { ProgressBar } from './ProgressBar'
import { fromNow } from '@/utils/time'
import { StudentTrack } from '@/components/types'

export const Track = ({ track }: { track: StudentTrack }): JSX.Element => {
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
                <div className="--v3"> Learning Mode </div>
              ) : track.isNew ? (
                <div className="--new">
                  <Icon icon="stars" alt="This track is new" />
                  New
                </div>
              ) : null}
            </div>
          )}
          {track.hasNotifications && <div className="c-notification-dot" />}
          {track.isJoined && (
            <div className="--joined">
              <GraphicalIcon icon="checkmark" className="lg:mr-8" />
              <span className="hidden lg:block">Joined</span>
            </div>
          )}
        </div>
        <ul className="--counts">
          <li>
            <Icon icon="exercises" alt="Number of exercises" />
            {track.numCompletedExercises == undefined
              ? null
              : `${track.numCompletedExercises}/`}
            {track.numExercises} {pluralize('exercise', track.numExercises)}
          </li>

          {track.course && (
            <li>
              <Icon icon="concepts" alt="Number of concepts" />
              {track.numCompletedConcepts == undefined
                ? null
                : `${track.numCompletedConcepts}/`}
              {track.numConcepts} {pluralize('concept', track.numConcepts)}
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
            Last touched {fromNow(track.lastTouchedAt)}
          </div>
        )}
      </div>
    </a>
  )
}
