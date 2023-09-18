import React from 'react'
import { Track } from './Track'
import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import { StudentTrack } from '@/components/types'

export const List = ({
  data,
  onReset,
}: {
  data: StudentTrack[]
  onReset: () => void
}): JSX.Element => {
  if (data.length === 0) {
    return (
      <div className="empty-state">
        <GraphicalIcon icon="sad-exercism" className="mb-20" />
        <h3 className="text-h3 mb-24">No results found</h3>
        <button type="button" onClick={onReset} className="btn-enhanced btn-s">
          <GraphicalIcon icon="reset" />
          <span>Reset search and filters</span>
        </button>
      </div>
    )
  }

  const joinedTracks = data.filter((track) => track.isJoined)
  const unjoinedTracks = data.filter((track) => !track.isJoined)

  return (
    <div className="--tracks">
      {joinedTracks.length !== 0 ? (
        <div className="joined-tracks">
          {joinedTracks.map((track) => {
            return <Track key={track.slug} track={track} />
          })}
        </div>
      ) : null}
      {unjoinedTracks.length !== 0 ? (
        <div className="unjoined-tracks">
          {unjoinedTracks.map((track) => {
            return <Track key={track.slug} track={track} />
          })}
        </div>
      ) : null}
    </div>
  )
}
