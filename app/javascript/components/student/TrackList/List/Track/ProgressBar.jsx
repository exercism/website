import React from 'react'

export function ProgressBar({
  numConceptExercises,
  numPracticeExercises,
  numCompletedConceptExercises,
  numCompletedPracticeExercises,
}) {
  const total = numConceptExercises + numPracticeExercises

  return (
    <p data-testid="track-progress-bar">
      Completed concept exercises:{' '}
      {(numCompletedConceptExercises / total) * 100}%, Uncompleted concept
      exercises:{' '}
      {((numConceptExercises - numCompletedConceptExercises) / total) * 100}%,
      Completed practice exercises:{' '}
      {(numCompletedPracticeExercises / total) * 100}%, Uncompleted practice
      exercises:{' '}
      {((numPracticeExercises - numCompletedPracticeExercises) / total) * 100}%
    </p>
  )
}
