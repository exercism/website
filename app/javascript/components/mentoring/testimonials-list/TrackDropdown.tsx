import React, { useCallback } from 'react'
import { TrackSelect, TrackLogo } from '../../common/TrackSelect'
import { Track } from '../TestimonialsList'

const OptionComponent = ({ option: track }: { option: Track }) => {
  return (
    <React.Fragment>
      <TrackLogo track={track} />
      <div className="title">{track.title}</div>
    </React.Fragment>
  )
}

const SelectedComponent = ({ option: track }: { option: Track }) => {
  return <TrackLogo track={track} />
}

export const TrackDropdown = ({
  tracks,
  value,
  setValue,
}: {
  tracks: readonly Track[]
  value: string
  setValue: (value: string) => void
}): JSX.Element => {
  const track = tracks.find((track) => track.id === value) || tracks[0]
  const handleSet = useCallback(
    (track) => {
      setValue(track.id)
    },
    [setValue]
  )

  return (
    <TrackSelect
      tracks={tracks}
      value={track}
      setValue={handleSet}
      OptionComponent={OptionComponent}
      SelectedComponent={SelectedComponent}
    />
  )
}
