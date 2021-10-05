import React from 'react'
import { ExerciseIcon } from '../../../common'
import { Exercise } from '../../../types'

export const UnlockedExercise = ({ title, iconUrl }: Exercise): JSX.Element => {
  return (
    <div key={title} className="c-exercise-widget --skinny --interactive">
      <ExerciseIcon iconUrl={iconUrl} />
      <div className="--info">
        <div className="--title">{title}</div>
      </div>
    </div>
  )
}
