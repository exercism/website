import React from 'react'

type TrackIconProps = {
  iconUrl: string
  title: string
  className?: string
}

export function TrackIcon({ iconUrl, title, className }: TrackIconProps) {
  let classNames = ['c-icon c-track-icon']
  if (className !== undefined) {
    classNames.push(className)
  }

  return (
    <img
      className={classNames.join(' ')}
      src={iconUrl}
      alt={`icon for ${title} track`}
    />
  )
}
