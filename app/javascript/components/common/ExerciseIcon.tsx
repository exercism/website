import React from 'react'
import { loadIcon } from '../../utils/icon-loader'

type ExerciseIconProps = {
  iconUrl: string
  title?: string
  className?: string
}

const errorIcon = loadIcon('missing-exercise', 'graphics')

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
