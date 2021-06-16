import React from 'react'
import { TrackIcon, GraphicalIcon } from '.'
import { Track } from '../types'
import { SingleSelect } from './SingleSelect'

const TrackLogo = ({ track }: { track: Track }) => {
  return track.id ? (
    <TrackIcon iconUrl={track.iconUrl} title={track.title} />
  ) : (
    <GraphicalIcon icon="all-tracks" className="all" />
  )
}

const TrackFilter = ({ option: track }: { option: Track }): JSX.Element => {
  return (
    <React.Fragment>
      <TrackLogo track={track} />
      <div className="title">{track.title}</div>
    </React.Fragment>
  )
}

const SelectedComponent = ({ option: track }: { option: Track }) => {
  return (
    <React.Fragment>
      <TrackLogo track={track} />
      <div className="track-title">{track.title}</div>
    </React.Fragment>
  )
}

export const TrackSelect = ({
  tracks,
  value,
  setValue,
  small = false,
}: {
  tracks: readonly Track[]
  value: Track
  setValue: (value: Track) => void
  small?: boolean
}): JSX.Element => {
  const classNames = ['c-track-switcher', small ? '--small' : ''].filter(
    (className) => className.length > 0
  )

  return (
    <SingleSelect<Track>
      options={tracks}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={TrackFilter}
      componentClassName={classNames.join(' ')}
    />
  )
}
