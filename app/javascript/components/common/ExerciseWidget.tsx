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
  return solution ? (
    <a href={solution.url} className="c-exercise-widget">
      <ExerciseIcon iconUrl={exercise.iconUrl} title={exercise.title} />
      <div className="--info">
        <div className="--title">{exercise.title}</div>
      </div>
      <SolutionStatusSummary status={solution.status} />
      {solution.numComments > 0 ? <span>{solution.numComments}</span> : null}
      {solution.numIterations > 0 ? (
        <span>
          {solution.numIterations}{' '}
          {pluralize('iteration', solution.numIterations)}
        </span>
      ) : null}
      <GraphicalIcon icon="chevron-right" className="--chevron-icon" />
    </a>
  ) : (
    <WidgetWrapper exercise={exercise} size={size}>
      <ExerciseIcon iconUrl={exercise.iconUrl} title={exercise.title} />
      <Info exercise={exercise} size={size} showDesc={showDesc} />
      <Status exercise={exercise} />
      <Difficulty difficulty={exercise.difficulty} />
      <WidgetIcon exercise={exercise} size={size} />
    </WidgetWrapper>
  )
}

const WidgetWrapper = ({
  exercise,
  size,
  children,
}: React.PropsWithChildren<{ exercise: Exercise; size: Size }>) => {
  const classNames = [
    'c-exercise-widget',
    exercise.isAvailable ? '' : '--locked',
    `--${size}`,
  ].filter((className) => className.length > 0)

  return exercise.isAvailable ? (
    <a href={exercise.links.self} className={classNames.join(' ')}>
      {children}
    </a>
  ) : (
    <div className={classNames.join(' ')}>{children}</div>
  )
}

const Info = ({
  exercise,
  size,
  showDesc,
}: {
  exercise: Exercise
  size: Size
  showDesc: boolean
}) => {
  return (
    <div className="--info">
      <div className="--title">
        {exercise.title}
        {exercise.isCompleted ? (
          <Icon icon="completed-check-circle" alt="Exercise is completed" />
        ) : null}
      </div>
      {size !== 'small' && showDesc ? (
        <div className="--desc">{exercise.blurb}</div>
      ) : null}
    </div>
  )
}

const SolutionStatusSummary = ({ status }: { status: SolutionStatus }) => {
  switch (status) {
    case 'completed':
      return <span>Completed</span>
    case 'inProgress':
      return <span>In progress</span>
    case 'published':
      return <span>Published</span>
    case 'started':
      return <span>Started</span>
  }
}

const Status = ({ exercise }: { exercise: Exercise }) => {
  return exercise.isAvailable ? <span>Available</span> : <span>Locked</span>
}

const Difficulty = ({ difficulty }: { difficulty: ExerciseDifficulty }) => {
  switch (difficulty) {
    case 'easy':
      return <span>Easy</span>
    default:
      return null
  }
}

const WidgetIcon = ({ exercise, size }: { exercise: Exercise; size: Size }) => {
  return exercise.isAvailable ? (
    size !== 'small' ? (
      <GraphicalIcon icon="chevron-right" className="--chevron-icon" />
    ) : null
  ) : (
    <Icon icon="lock" className="--lock-icon" alt="Exercise locked" />
  )
}
