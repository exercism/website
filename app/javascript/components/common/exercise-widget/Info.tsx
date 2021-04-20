import React from 'react'
import pluralize from 'pluralize'
import { TrackIcon } from '../TrackIcon'
import { Exercise, Track, SolutionForStudent } from '../../types'
import { GraphicalIcon } from '../GraphicalIcon'
import { SolutionStatusTag } from './SolutionStatusTag'
import { ExerciseStatusTag } from './ExerciseStatusTag'
import { Difficulty } from './Difficulty'

export const Info = ({
  exercise,
  track,
  solution,
}: {
  exercise: Exercise
  track: Track
  solution?: SolutionForStudent
}): JSX.Element => {
  return (
    <div className="--info">
      <div className="--title">
        {exercise.title}
        <div className="--track">
          in <TrackIcon iconUrl={track.iconUrl} title={track.title} />
          <div className="--track-title">{track.title}</div>
        </div>
        {solution && solution.hasNotifications ? (
          <div className="c-notification-dot">
            <span className="tw-sr-only">has notifications</span>
          </div>
        ) : null}
      </div>
      <div className="--data">
        {solution ? (
          <SolutionStatusTag status={solution.status} />
        ) : (
          <ExerciseStatusTag exercise={exercise} />
        )}
        {solution ? null : <Difficulty difficulty={exercise.difficulty} />}

        {solution && solution.numIterations > 0 ? (
          <div className="--iterations-count">
            <GraphicalIcon icon="iteration" />
            {solution.numIterations}{' '}
            {pluralize('iteration', solution.numIterations)}
          </div>
        ) : null}
        {solution && solution.numMentoringComments > 0 ? (
          <div className="--mentor-comments-count">
            <GraphicalIcon icon="mentoring" />
            {solution.numMentoringComments}
          </div>
        ) : null}
      </div>
      <div className="--blurb">{exercise.blurb}</div>
    </div>
  )
}
