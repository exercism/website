import React from 'react'

type TrackIconProps = {
  iconUrl: string
  title: string
}

export function TrackIcon({ track }: { track: TrackIconProps }) {
  return (
    <img
      className="c-track-icon"
      src={track.iconUrl}
      alt={`icon for ${track.title} track`}
    />
  )
}
