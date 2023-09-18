import React, { useCallback } from 'react'
import { TrackSelect, TrackLogo } from '@/components/common/TrackSelect'
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
  return (
    <>
      <TrackLogo track={track} />
      <div className="sr-only">{track.title}</div>
    </>
  )
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
  const track = tracks.find((track) => track.slug === value) || tracks[0]
  const handleSet = useCallback(
    (track: Track) => {
      setValue(track.slug)
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
      size="inline"
    />
  )
}
