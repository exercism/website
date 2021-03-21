import * as React from 'react'
import { ExerciseStatus, IConcept } from './concept-map-types'
import { camelize } from 'humps'
import { useExerciseStatusIndex } from './hooks/useExerciseStatusIndex'

export const ExerciseStatusBar = ({
  conceptExercises,
  practiceExercises,
}: IConcept['exercises']): JSX.Element | null => {
  const statusIndex = useExerciseStatusIndex()

  if (conceptExercises.length + practiceExercises.length === 0) {
    return null
  }

  return (
    <div className="exercise-status-bar">
      {conceptExercises.map((exercise, i) =>
        statusMapper(statusIndex[camelize(exercise)], i)
      )}
      {practiceExercises.map((exercise, i) =>
        statusMapper(statusIndex[camelize(exercise)], i)
      )}
    </div>
  )
}

export const PureExerciseStatusBar = React.memo(ExerciseStatusBar)

const statusMapper = (status: ExerciseStatus, key: number): JSX.Element => {
  return <div key={key} className={`c-exercise-dot ${status}`} />
}
