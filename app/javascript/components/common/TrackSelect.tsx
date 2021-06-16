import React from 'react'
import { TrackIcon, GraphicalIcon } from '.'
import { Track as BaseTrack } from '../types'
import { SingleSelect } from './SingleSelect'

type Track = Pick<BaseTrack, 'iconUrl' | 'id' | 'title'>

export const TrackLogo = <T extends Track>({
  track,
}: {
  track: T
}): JSX.Element => {
  return track.id ? (
    <TrackIcon iconUrl={track.iconUrl} title={track.title} />
  ) : (
    <GraphicalIcon icon="all-tracks" className="all" />
  )
}

const DefaultOptionComponent = <T extends Track>({
  option: track,
}: {
  option: T
}): JSX.Element => {
  return (
    <React.Fragment>
      <TrackLogo track={track} />
      <div className="title">{track.title}</div>
    </React.Fragment>
  )
}

const DefaultSelectedComponent = <T extends Track>({
  option: track,
}: {
  option: T
}) => {
  return (
    <React.Fragment>
      <TrackLogo track={track} />
      <div className="track-title">{track.title}</div>
    </React.Fragment>
  )
}

export const TrackSelect = <T extends Track>({
  tracks,
  value,
  setValue,
  small = false,
  SelectedComponent = DefaultSelectedComponent,
  OptionComponent = DefaultOptionComponent,
}: {
  tracks: readonly T[]
  value: T
  setValue: (value: T) => void
  small?: boolean
  SelectedComponent?: React.ComponentType<{ option: T }>
  OptionComponent?: React.ComponentType<{ option: T }>
}): JSX.Element => {
  const classNames = ['c-track-switcher', small ? '--small' : ''].filter(
    (className) => className.length > 0
  )

  return (
    <SingleSelect<T>
      options={tracks}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
      componentClassName={classNames.join(' ')}
    />
  )
}
