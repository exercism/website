import React from 'react'
import { missingTrackIconErrorHandler } from './imageErrorHandler'

type TrackIconProps = {
  iconUrl: string
  title: string
  className?: string
}

export function TrackIcon({
  iconUrl,
  title,
  className,
}: TrackIconProps): JSX.Element {
  const classNames = ['c-icon c-track-icon']
  if (className !== undefined) {
    classNames.push(className)
  }

  return (
    <img
      className={classNames.join(' ')}
      src={iconUrl}
      alt={`icon for ${title} track`}
      onError={missingTrackIconErrorHandler}
    />
  )
}
