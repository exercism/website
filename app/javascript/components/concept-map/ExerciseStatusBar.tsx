import * as React from 'react'
import { ExerciseStatusDot } from '../student'
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
    <div className="exercise-status-bar hidden lg:flex">
      {exercisesData.map((data, i) => statusMapper(data, i))}
    </div>
  )
}

export const PureExerciseStatusBar = React.memo(ExerciseStatusBar)

const statusMapper = (data: ExerciseData, key: number): JSX.Element => {
  return (
    <ExerciseStatusDot
      key={key}
      exerciseStatus={data.status}
      type={data.type}
      links={{ tooltip: data.tooltipUrl, exercise: data.url }}
    />
  )
}
