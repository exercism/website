import React from 'react'
import { GraphicalIcon } from '../../common'

export const UnlockedExercise = ({
  title,
  iconName,
}: {
  title: string
  iconName: string
}): JSX.Element => {
  return (
    <div key={title} className="exercise">
      <GraphicalIcon icon={iconName} className="c-exercise-icon" />
      <div className="title">{title}</div>
    </div>
  )
}
