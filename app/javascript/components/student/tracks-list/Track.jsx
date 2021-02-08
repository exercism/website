import React from 'react'
import { TrackIcon } from '../../common/TrackIcon'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Icon } from '../../common/Icon'
import { ProgressBar } from './ProgressBar'

export function Track({ track }) {
  return (
    <a className="--track" href={track.webUrl}>
      <div className="--content">
        <TrackIcon iconUrl={track.iconUrl} title={track.title} />
        <div className="--info">
          <div className="--heading">
            <h3 className="--title">{track.title}</h3>
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
          <ul className="--tags">
            {track.tags.slice(0, 3).map((tag) => {
              // TODO: find a nice solution to map tags to their human-readable form
              return <li key={tag}>{tag.split('/')[1]}</li>
            })}
          </ul>
        </div>
        <GraphicalIcon icon="chevron-right" />
      </div>

      {track.isJoined && (
        <ProgressBar
          numConceptExercises={track.numConceptExercises}
          numPracticeExercises={track.numPracticeExercises}
          numCompletedConceptExercises={track.numCompletedConceptExercises}
          numCompletedPracticeExercises={track.numCompletedPracticeExercises}
        />
      )}
    </a>
  )
}
