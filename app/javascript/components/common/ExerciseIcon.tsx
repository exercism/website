import React from 'react'
import { GraphicalIcon } from './GraphicalIcon'

export const ExerciseIcon = ({ icon }: { icon: string }): JSX.Element => {
  const tmpIconName = icon.replace('sample', 'sample-exercise')
  return <GraphicalIcon icon={tmpIconName} className="c-exercise-icon" />
}
