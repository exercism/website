import React from 'react'
import { missingExerciseIconErrorHandler } from '../common'

type ExerciseIconProps = {
  iconUrl: string
  title?: string
  className?: string
}

export function ExerciseIcon({ iconUrl, title, className }: ExerciseIconProps) {
  const classNames = ['c-icon c-exercise-icon']
  if (className !== undefined) {
    classNames.push(className)
  }

  return (
    <img
      className={classNames.join(' ')}
      src={iconUrl}
      alt={title ? `Icon for exercise called ${title}` : undefined}
      role={title ? undefined : 'presentation'}
      onError={missingExerciseIconErrorHandler}
    />
  )
}
