import React from 'react'
import { Track } from './Track'

export function List({ data }) {
  if (data.tracks.length == 0) {
    return <p>No results found</p>
  }

  return (
    <div className="tracks">
      {data.tracks.map((track) => {
        return <Track key={track.id} track={track} />
      })}
    </div>
  )
}
