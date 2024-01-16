import React from 'react'
import { missingTrackIconErrorHandler } from './imageErrorHandler'
import { assetUrl } from '@/utils/assets'

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
      src={iconUrl || assetUrl('icons/all-tracks.svg')}
      alt={`icon for ${title} track`}
      onError={missingTrackIconErrorHandler}
    />
  )
}
