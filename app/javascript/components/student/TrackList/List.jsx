import React from 'react'
import { Track } from './List/Track'

export function List({ data }) {
  if (data.tracks.length == 0) {
    return <p>No results found</p>
  }

  return (
    <table>
      <thead>
        <tr>
          <th>Icon</th>
          <th>Title</th>
          <th>Num concept exercises</th>
          <th>Num practice exercises</th>
          <th>URL</th>
          <th>New?</th>
          <th>Tags</th>
          <th>Joined?</th>
          <th>Num completed concept exercises</th>
          <th>Num completed practice exercises</th>
        </tr>
      </thead>
      <tbody>
        {data.tracks.map((track) => {
          return <Track key={track.id} track={track} />
        })}
      </tbody>
    </table>
  )
}
