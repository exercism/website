import React, { useCallback } from 'react'
import { TrackSelect, TrackLogo } from '../../common/TrackSelect'

export type Track = {
  id: string
  title: string
  iconUrl: string
  count: number
}

const OptionComponent = ({ option: track }: { option: Track }) => {
  return (
    <React.Fragment>
      <TrackLogo track={track} />
      <div className="title">{track.title}</div>
      <div className="count">{track.count}</div>
    </React.Fragment>
  )
}

const SelectedComponent = ({ option: track }: { option: Track }) => {
  return <TrackLogo track={track} />
}

export const TrackList = ({
  tracks,
  value,
  setTrack,
}: {
  tracks: Track[]
  value: string | null
  setTrack: (value: string | null) => void
}): JSX.Element => {
  const track = tracks.find((t) => t.id === value) || tracks[0]

  const handleSet = useCallback(
    (track) => {
      setTrack(track.id)
    },
    [setTrack]
  )

  return (
    <TrackSelect<Track>
      tracks={tracks}
      value={track}
      setValue={handleSet}
      OptionComponent={OptionComponent}
      SelectedComponent={SelectedComponent}
    />
  )
}
