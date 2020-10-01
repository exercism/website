import React from 'react'

export function TrackIcon({ track, width = 100 }) {
  return (
    <img
      style={{ width: width }}
      src={track.iconUrl}
      alt={`icon for ${track.title} track`}
    />
  )
}
