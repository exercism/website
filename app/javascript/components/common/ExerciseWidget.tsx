import pluralize from 'pluralize'
import React from 'react'
import {
  Track,
  Exercise,
  ExerciseDifficulty,
  SolutionForStudent,
  SolutionStatus,
} from '../types'
import { TrackIcon } from './TrackIcon'
import { ExerciseIcon } from './ExerciseIcon'
import { GraphicalIcon } from './GraphicalIcon'

type Size = 'small' | 'medium' | 'large' | 'tooltip'

export const ExerciseWidget = ({
  exercise,
  track,
  solution,
  size,
}: {
  exercise: Exercise
  track: Track
  solution?: SolutionForStudent
  size: Size
}): JSX.Element => {
  if (solution) {
    return (
      <a
        href={solution.url}
        className={`c-exercise-widget --${solution.status} --${size}`}
      >
        <ExerciseIcon iconUrl={exercise.iconUrl} title={exercise.title} />
        <Info exercise={exercise} solution={solution} track={track} />
        <GraphicalIcon icon="chevron-right" className="--action-icon" />
      </a>
    )
  } else if (exercise.isAvailable) {
    return (
      <a
        href={exercise.links.self}
        className={`c-exercise-widget --available --${size}`}
      >
        <ExerciseIcon iconUrl={exercise.iconUrl} title={exercise.title} />
        <Info exercise={exercise} solution={solution} track={track} />
        <GraphicalIcon icon="chevron-right" className="--action-icon" />
      </a>
    )
  } else {
    return (
      <div className={`c-exercise-widget --locked --${size}`}>
        <ExerciseIcon iconUrl={exercise.iconUrl} title={exercise.title} />
        <Info exercise={exercise} solution={solution} track={track} />
        <GraphicalIcon icon="lock" className="--action-icon" />
      </div>
    )
  }
}

const Info = ({
  exercise,
  track,
  solution,
}: {
  exercise: Exercise
  track: Track
  solution?: SolutionForStudent
}) => {
  return (
    <div className="--info">
      <div className="--title">
        {exercise.title}
        <div className="--track">
          in <TrackIcon iconUrl={track.iconUrl} title={track.title} />
          <div className="--track-title">{track.title}</div>
        </div>
        {solution && solution.hasNotifications ? (
          <div className="c-notification-dot" />
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

const SolutionStatusTag = ({ status }: { status: SolutionStatus }) => {
  switch (status) {
    case 'published':
      return <div className="c-exercise-status-tag --published">Published</div>
    case 'completed':
      return <div className="c-exercise-status-tag --completed">Completed</div>
    case 'in_progress':
      return (
        <div className="c-exercise-status-tag --in-progress">In-progress</div>
      )
    case 'started':
      return (
        <div className="c-exercise-status-tag --in-progress">In-progress</div>
      )
  }
}

const ExerciseStatusTag = ({ exercise }: { exercise: Exercise }) => {
  if (exercise.isRecommended) {
    return (
      <div className="c-exercise-status-tag --recommended">Recommended</div>
    )
  } else if (exercise.isAvailable) {
    return <div className="c-exercise-status-tag --available">Available</div>
  } else {
    return <div className="c-exercise-status-tag --locked">Locked</div>
  }
}

const Difficulty = ({ difficulty }: { difficulty: ExerciseDifficulty }) => {
  switch (difficulty) {
    case 'easy':
      return <div className="--difficulty --easy">Easy</div>
    default:
      return null
  }
}
