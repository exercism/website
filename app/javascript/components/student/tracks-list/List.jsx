import React from 'react'
import { Track } from './Track'

export function List({ data }) {
  const { tracks } = data
  const joinedTracks = tracks.filter((track) => track.isJoined)
  const unjoinedTracks = tracks.filter((track) => !track.isJoined)

  if (tracks.length == 0) {
    return <p>No results found</p>
  }

  return (
    <div className="--tracks">
      {joinedTracks.length !== 0 ? (
        <div className="joined-tracks">
          {joinedTracks.map((track) => {
            return <Track key={track.id} track={track} />
          })}
        </div>
      ) : null}
      {unjoinedTracks.length !== 0 ? (
        <div className="unjoined-tracks">
          {unjoinedTracks.map((track) => {
            return <Track key={track.id} track={track} />
          })}
        </div>
      ) : null}
    </div>
  )
}
