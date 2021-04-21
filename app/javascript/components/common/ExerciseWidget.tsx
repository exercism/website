import React from 'react'
import { Track, Exercise, SolutionForStudent } from '../types'
import { ExerciseIcon } from './ExerciseIcon'
import { GraphicalIcon } from './GraphicalIcon'
import { Info } from './exercise-widget/Info'

type Size = 'tiny' | 'small' | 'medium' | 'large' | 'tooltip'

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
  } else if (exercise.isUnlocked) {
    const classNames = [
      'c-exercise-widget',
      '--available',
      `--${size}`,
      exercise.isRecommended ? '--recommended' : '',
    ].filter((name) => name.length > 0)
    return (
      <a href={exercise.links.self} className={classNames.join(' ')}>
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
