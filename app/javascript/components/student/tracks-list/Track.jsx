import React from 'react'
import { TrackIcon } from '../../common/TrackIcon'
import { Icon } from '../../common/Icon'
import { ProgressBar } from './ProgressBar'
import { fromNow } from '../../../utils/time'

export function Track({ track }) {
  return (
    <a className="--track" href={track.webUrl}>
      <TrackIcon iconUrl={track.iconUrl} title={track.title} />
      <div className="--info">
        <div className="--heading">
          <h3 className="--title">{track.title}</h3>
          {track.numConcepts > 5 ? (
            <div className="--v3">
              <Icon icon="concepts" alt="This track has Concepts" />
              V3
            </div>
          ) : null}
          {track.isNew ? (
            <div className="--new">
              <Icon icon="stars" alt="This track is new" />
              New
            </div>
          ) : null}
          {track.isJoined && <div className="--joined">Joined</div>}
        </div>
        <ul className="--counts">
          <li>
            <Icon icon="exercises" alt="Number of exercises" />
            {track.numCompletedPracticeExercises == undefined
              ? null
              : `${track.numCompletedPracticeExercises}/`}
            {track.numPracticeExercises} exercises
          </li>
          <li>
            <Icon icon="concepts" alt="Number of concepts" />
            {track.numCompletedConceptExercises == undefined
              ? null
              : `${track.numCompletedConceptExercises}/`}
            {track.numConceptExercises} concepts
          </li>
        </ul>

        {track.isJoined && (
          <ProgressBar
            numConceptExercises={track.numConceptExercises}
            numPracticeExercises={track.numPracticeExercises}
            numCompletedConceptExercises={track.numCompletedConceptExercises}
            numCompletedPracticeExercises={track.numCompletedPracticeExercises}
          />
        )}

        <ul className="--tags">
          {track.tags.slice(0, 3).map((tag) => {
            // TODO: find a nice solution to map tags to their human-readable form
            return <li key={tag}>{tag.split('/')[1]}</li>
          })}
        </ul>

        {track.isJoined && (
          <div className="--last-touched">
            Last Touched {fromNow(track.updatedAt)}
          </div>
        )}
      </div>
    </a>
  )
}
