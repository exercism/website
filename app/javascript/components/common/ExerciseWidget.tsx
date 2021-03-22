import React from 'react'
import { Exercise, ExerciseDifficulty } from '../types'
import { ExerciseIcon } from './ExerciseIcon'
import { GraphicalIcon } from './GraphicalIcon'
import { Icon } from './Icon'

export const ExerciseWidget = ({
  exercise,
}: {
  exercise: Exercise
}): JSX.Element => {
  return (
    <WidgetWrapper exercise={exercise}>
      <ExerciseIcon iconUrl={exercise.iconUrl} title={exercise.title} />
      <div className="--info">
        <div className="--title">{exercise.title}</div>
        <div className="--desc">{exercise.blurb}</div>
      </div>
      <Status exercise={exercise} />
      <Difficulty difficulty={exercise.difficulty} />
      <WidgetIcon exercise={exercise} />
    </WidgetWrapper>
  )
}

const WidgetWrapper = ({
  exercise,
  children,
}: React.PropsWithChildren<{ exercise: Exercise }>) => {
  return exercise.isAvailable ? (
    <a href={exercise.links.self} className="c-exercise-widget">
      {children}
    </a>
  ) : (
    <div className="c-exercise-widget --locked">{children}</div>
  )
}

const Status = ({ exercise }: { exercise: Exercise }) => {
  return exercise.isAvailable ? <span>Available</span> : <span>Locked</span>
}

const Difficulty = ({ difficulty }: { difficulty: ExerciseDifficulty }) => {
  switch (difficulty) {
    case 'easy':
      return <span>Easy</span>
  }
}

const WidgetIcon = ({ exercise }: { exercise: Exercise }) => {
  return exercise.isAvailable ? (
    <GraphicalIcon icon="chevron-right" className="--chevron-icon" />
  ) : (
    <Icon icon="lock" className="--lock-icon" alt="Exercise locked" />
  )
}
