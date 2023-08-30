import React, { useCallback } from 'react'
import { TrackData } from '../CommunitySolutionsList'
import { TrackSelect, TrackLogo } from '@/components/common/TrackSelect'

const OptionComponent = ({
  option: track,
}: {
  option: TrackData
}): JSX.Element => {
  return (
    <React.Fragment>
      <TrackLogo track={track} />
      <div className="title">{track.title}</div>
      <div className="count">{track.numSolutions}</div>
    </React.Fragment>
  )
}

const SelectedComponent = ({
  option: track,
}: {
  option: TrackData
}): JSX.Element => {
  return (
    <React.Fragment>
      <TrackLogo track={track} />
      <div className="track-title">{track.title}</div>
      <div className="count">{track.numSolutions}</div>
    </React.Fragment>
  )
}

export const TrackDropdown = ({
  tracks,
  value,
  setValue,
}: {
  tracks: TrackData[]
  value: string
  setValue: (slug: string | null) => void
}): JSX.Element | null => {
  const track = tracks.find((track) => track.slug === value) || tracks[0]
  const handleSet = useCallback(
    (track: TrackData) => {
      setValue(track.slug)
    },
    [setValue]
  )

  return (
    <TrackSelect<TrackData>
      tracks={tracks}
      value={track}
      setValue={handleSet}
      OptionComponent={OptionComponent}
      SelectedComponent={SelectedComponent}
      size="single"
    />
  )
}
