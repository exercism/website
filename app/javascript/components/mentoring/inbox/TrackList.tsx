import React, { useCallback } from 'react'
import { TrackSelect, TrackLogo } from '@/components/common/TrackSelect'

export type Track = {
  slug: string
  title: string
  iconUrl: string
  count?: number
}

const OptionComponent = ({ option: track }: { option: Track }) => {
  return (
    <React.Fragment>
      <TrackLogo track={track} />
      <div className="title">{track.title}</div>
      <div className="count">{track.count}</div>
      {/* TODO: {track.count && <div className="count">{track.count}</div>} */}
    </React.Fragment>
  )
}

const SelectedComponent = ({ option: track }: { option: Track }) => {
  return (
    <div>
      <TrackLogo track={track} />
      <div className="sr-only">{track.title}</div>
    </div>
  )
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
  const track = tracks.find((t) => t.slug === value) || tracks[0]

  const handleSet = useCallback(
    (track: Track) => {
      setTrack(track.slug)
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
      size="inline"
    />
  )
}
