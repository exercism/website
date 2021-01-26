import React from 'react'
import { GraphicalIcon } from '../../common'
import { Exercise } from '../CompleteExerciseModal'

export const UnlockedExercise = ({
  title,
  iconName,
}: Exercise): JSX.Element => {
  return (
    <div key={title} className="exercise">
      <GraphicalIcon icon={iconName} className="c-exercise-icon" />
      <div className="title">{title}</div>
    </div>
  )
}
