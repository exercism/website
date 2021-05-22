import React from 'react'
import { Exercise, Size } from '../../types'

export const ExerciseStatusTag = ({
  exercise,
  size,
}: {
  exercise: Exercise
  size?: Size
}): JSX.Element => {
  if (exercise.isExternal) {
    return <></>
  }

  const sizeClassName = size ? `--${size}` : ''

  if (exercise.isRecommended) {
    return (
      <div className={`c-exercise-status-tag --recommended ${sizeClassName}`}>
        Recommended
      </div>
    )
  } else if (exercise.isUnlocked) {
    return (
      <div className={`c-exercise-status-tag --available ${sizeClassName}`}>
        Available
      </div>
    )
  } else {
    return (
      <div className={`c-exercise-status-tag --locked ${sizeClassName}`}>
        Locked
      </div>
    )
  }
}
