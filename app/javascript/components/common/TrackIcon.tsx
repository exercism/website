import React from 'react'

type TrackIconProps = {
  iconUrl: string
  title: string
}

export function TrackIcon({ iconUrl, title }: TrackIconProps) {
  return (
    <img
      className="c-track-icon"
      src={iconUrl}
      alt={`icon for ${title} track`}
    />
  )
}
