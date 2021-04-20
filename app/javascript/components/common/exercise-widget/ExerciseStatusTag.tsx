import React from 'react'
import { Exercise } from '../../types'

export const ExerciseStatusTag = ({
  exercise,
}: {
  exercise: Exercise
}): JSX.Element => {
  if (exercise.isRecommended) {
    return (
      <div className="c-exercise-status-tag --recommended">Recommended</div>
    )
  } else if (exercise.isUnlocked) {
    return <div className="c-exercise-status-tag --available">Available</div>
  } else {
    return <div className="c-exercise-status-tag --locked">Locked</div>
  }
}
