import pluralize from 'pluralize'
import React from 'react'
import {
  Exercise,
  ExerciseDifficulty,
  SolutionForStudent,
  SolutionStatus,
} from '../types'
import { ExerciseIcon } from './ExerciseIcon'
import { GraphicalIcon } from './GraphicalIcon'
import { Icon } from './Icon'

type Size = 'small' | 'medium' | 'large'

export const ExerciseWidget = ({
  exercise,
  solution,
  size,
  showDesc = true,
}: {
  exercise: Exercise
  solution?: SolutionForStudent
  size: Size
  showDesc?: boolean
}): JSX.Element => {
  if (solution) {
    return (
      <a
        href={solution.url}
        className={`c-exercise-widget --${solution.status} --${size}`}
      >
        <ExerciseIcon iconUrl={exercise.iconUrl} title={exercise.title} />
        <Info exercise={exercise} solution={solution} />
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
        <Info exercise={exercise} solution={solution} />
        <GraphicalIcon icon="chevron-right" className="--action-icon" />
      </a>
    )
  } else {
    return (
      <div className={`c-exercise-widget --locked --${size}`}>
        <ExerciseIcon iconUrl={exercise.iconUrl} title={exercise.title} />
        <Info exercise={exercise} solution={solution} />
        <GraphicalIcon icon="lock" className="--action-icon" />
      </div>
    )
  }
}

const Info = ({
  exercise,
  solution,
}: {
  exercise: Exercise
  solution?: SolutionForStudent
}) => {
  return (
    <div className="--info">
      <div className="--title">
        {exercise.title}
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

        {/* TODO: This should be num_mentoring_comments comments */}
        {solution && solution.numComments > 0 ? (
          <div className="--mentor-comments-count">
            <GraphicalIcon icon="mentoring" />
            {solution.numComments}
          </div>
        ) : null}
        {solution && solution.numIterations > 0 ? (
          <div className="--iterations-count">
            <GraphicalIcon icon="iteration" />
            {solution.numIterations}{' '}
            {pluralize('iteration', solution.numIterations)}
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
