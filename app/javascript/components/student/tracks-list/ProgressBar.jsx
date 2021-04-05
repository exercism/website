import React from 'react'

export function ProgressBar({ numExercises, numCompletedExercises }) {
  console.log(numExercises)
  console.log(numCompletedExercises)
  const completedPercentage = (numCompletedExercises / numExercises) * 100 + '%'

  return (
    <div className="--progress-bar">
      <div className="--fill" style={{ width: completedPercentage }} />
    </div>
  )
}
