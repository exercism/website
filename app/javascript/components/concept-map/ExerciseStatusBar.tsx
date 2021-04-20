import * as React from 'react'
import { ExerciseData } from './concept-map-types'

export const ExerciseStatusBar = ({
  exercisesData,
}: {
  exercisesData: ExerciseData[]
}): JSX.Element | null => {
  if (exercisesData.length === 0) {
    return null
  }

  return (
    <div className="exercise-status-bar">
      {exercisesData.map((data, i) => statusMapper(data, i))}
    </div>
  )
}

export const PureExerciseStatusBar = React.memo(ExerciseStatusBar)

const statusMapper = (data: ExerciseData, key: number): JSX.Element => {
  return (
    <div
      key={key}
      className={`c-ed --${data.status} --${data.type} disabled`}
    />
  )
}
