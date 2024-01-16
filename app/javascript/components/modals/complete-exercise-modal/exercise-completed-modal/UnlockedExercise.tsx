import React from 'react'
import { ExerciseIcon } from '../../../common'
import { Exercise } from '../../../types'

export const UnlockedExercise = ({
  title,
  iconUrl,
  links,
}: Exercise): JSX.Element => {
  return (
    <a
      href={links.self}
      key={title}
      className="c-exercise-widget --skinny --interactive"
    >
      <ExerciseIcon iconUrl={iconUrl} />
      <div className="--info">
        <div className="--title">{title}</div>
      </div>
    </a>
  )
}
