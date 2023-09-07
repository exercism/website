import React from 'react'
import { missingExerciseIconErrorHandler } from '@/components/common/imageErrorHandler'

type ExerciseIconProps = {
  iconUrl: string
  title?: string
  className?: string
}

export function ExerciseIcon({
  iconUrl,
  title,
  className,
}: ExerciseIconProps): JSX.Element {
  const classNames = ['c-icon c-exercise-icon']
  if (className !== undefined) {
    classNames.push(className)
  }

  return (
    <img
      className={classNames.join(' ')}
      src={iconUrl}
      alt={title ? `Icon for exercise called ${title}` : ''}
      onError={missingExerciseIconErrorHandler}
    />
  )
}
