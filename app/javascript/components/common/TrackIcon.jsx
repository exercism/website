import React from 'react'

export function TrackIcon({ track }) {
  return (
    <img
      className="c-track-icon"
      src={track.iconUrl}
      alt={`icon for ${track.title} track`}
    />
  )
}
