import React from 'react'
import { Track } from './Track'

export function List({ data }) {
  if (data.tracks.length == 0) {
    return <p>No results found</p>
  }

  return (
    <section className="s-grid md:s-grid-cols-2 s-gap-16">
      {data.tracks.map((track) => {
        return <Track key={track.id} track={track} />
      })}
    </section>
  )
}
