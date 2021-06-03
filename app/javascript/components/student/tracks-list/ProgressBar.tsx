import React from 'react'

export const ProgressBar = ({
  numExercises,
  numCompletedExercises,
}: {
  numExercises: number
  numCompletedExercises: number
}): JSX.Element => {
  const completedPercentage = (numCompletedExercises / numExercises) * 100 + '%'

  return (
    <div className="--progress-bar">
      <div className="--fill" style={{ width: completedPercentage }} />
    </div>
  )
}
