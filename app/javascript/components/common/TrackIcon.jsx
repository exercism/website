import React from 'react'

export function TrackIcon({ track }) {
  return (
    <img
      style={{ width: 100 }}
      src={track.iconUrl}
      alt={`icon for ${track.title} track`}
    />
  )
}
