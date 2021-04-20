import React from 'react'

type ExerciseIconProps = {
  iconUrl: string
  title?: string
  className?: string
}

const errorIcon = require(`../../images/graphics/missing-exercise.svg`)

function imageErrorHandler(e: React.SyntheticEvent<HTMLImageElement, Event>) {
  const el = e.target as HTMLImageElement
  if ((el.src = errorIcon)) {
    return
  }
  el.onerror = null
  el.src = errorIcon
}

export function ExerciseIcon({ iconUrl, title, className }: ExerciseIconProps) {
  let classNames = ['c-icon c-exercise-icon']
  if (className !== undefined) {
    classNames.push(className)
  }

  return (
    <img
      className={classNames.join(' ')}
      src={iconUrl}
      alt={title ? `Icon for exercise called ${title}` : undefined}
      role={title ? undefined : 'presentation'}
      onError={imageErrorHandler}
    />
  )
}
