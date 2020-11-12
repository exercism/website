import React from 'react'

type Track = {
  iconUrl: string
  title: string
}

export function TrackIcon({ track }: { track: Track }) {
  return (
    <img
      className="c-track-icon"
      src={track.iconUrl}
      alt={`icon for ${track.title} track`}
    />
  )
}
