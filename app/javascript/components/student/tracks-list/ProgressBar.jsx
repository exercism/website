import React from 'react'

export function ProgressBar({
  numConceptExercises,
  numPracticeExercises,
  numCompletedConceptExercises,
  numCompletedPracticeExercises,
}) {
  const total = numConceptExercises + numPracticeExercises
  const numUncompletedPracticeExercises =
    numPracticeExercises - numCompletedPracticeExercises
  const numUncompletedConceptExercises =
    numConceptExercises - numCompletedConceptExercises

  const completedConceptPercentage =
    (numCompletedConceptExercises / total) * 100 + '%'
  const uncompletedConceptPercentage =
    (numUncompletedConceptExercises / total) * 100 + '%'
  const completedPracticePercentage =
    (numCompletedPracticeExercises / total) * 100 + '%'
  const uncompletedPracticePercentage =
    (numUncompletedPracticeExercises / total) * 100 + '%'

  return (
    <div className="--progress-bar">
      <div className="--cp" style={{ width: completedConceptPercentage }} />
      <div className="--ucp" style={{ width: uncompletedConceptPercentage }} />
      <div className="--ce" style={{ width: completedPracticePercentage }} />
      <div className="--uce" style={{ width: uncompletedPracticePercentage }} />
    </div>
  )
}
