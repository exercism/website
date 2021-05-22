import React from 'react'
import { Exercise, Size } from '../../types'

export const ExerciseStatusTag = ({
  exercise,
  size,
}: {
  exercise: Exercise
  size: Size
}): JSX.Element => {
  if (exercise.isExternal) {
    return <></>
  }

  if (exercise.isRecommended) {
    return (
      <div className={`c-exercise-status-tag --recommended --${size}`}>
        Recommended
      </div>
    )
  } else if (exercise.isUnlocked) {
    return (
      <div className={`c-exercise-status-tag --available --${size}`}>
        Available
      </div>
    )
  } else {
    return (
      <div className={`c-exercise-status-tag --locked --${size}`}>Locked</div>
    )
  }
}
