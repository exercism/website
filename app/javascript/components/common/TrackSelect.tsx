import React from 'react'
import { TrackIcon, GraphicalIcon } from '.'
import { SingleSelect } from './SingleSelect'

type Size = 'inline' | 'single' | 'multi' | 'large'

type Track = {
  title: string
  slug: string | null
  iconUrl: string
}

export const TrackLogo = <T extends Track>({
  track,
}: {
  track: T
}): JSX.Element => {
  return track.slug ? (
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
  size = 'single',
  SelectedComponent = DefaultSelectedComponent,
  OptionComponent = DefaultOptionComponent,
}: {
  tracks: readonly T[]
  value: T
  setValue: (value: T) => void
  size?: Size
  SelectedComponent?: React.ComponentType<{ option: T }>
  OptionComponent?: React.ComponentType<{ option: T }>
}): JSX.Element => {
  return (
    <SingleSelect<T>
      options={tracks}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
      className={`c-track-select --size-${size}`}
    />
  )
}
