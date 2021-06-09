import React from 'react'
import { TrackIcon, GraphicalIcon } from '.'
import { Track } from '../types'
import { ExercismSelect } from './ExercismSelect'

const TrackLogo = ({ track }: { track: Track }) => {
  return track.id ? (
    <TrackIcon iconUrl={track.iconUrl} title={track.title} />
  ) : (
    <GraphicalIcon icon="all-tracks" className="all" />
  )
}

const TrackFilter = ({
  option: track,
  checked,
  onChange,
}: {
  option: Track
  checked: boolean
  onChange: (e: React.ChangeEvent) => void
}): JSX.Element => {
  return (
    <label className="c-radio-wrapper">
      <input type="radio" onChange={onChange} checked={checked} />
      <div className="row">
        <TrackLogo track={track} />
        <div className="title">{track.title}</div>
      </div>
    </label>
  )
}

const SelectedComponent = ({ value: track }: { value: Track }) => {
  return (
    <React.Fragment>
      <TrackLogo track={track} />
      <div className="track-title">{track.title}</div>
    </React.Fragment>
  )
}

export const TrackSwitcher = ({
  tracks,
  value,
  setValue,
}: {
  tracks: readonly Track[]
  value: Track
  setValue: (value: Track) => void
}): JSX.Element => {
  return (
    <ExercismSelect<Track>
      options={tracks}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={TrackFilter}
      componentClassName="c-track-switcher --small"
      buttonClassName="current-track"
      panelClassName="c-track-switcher-dropdown"
    />
  )
}
