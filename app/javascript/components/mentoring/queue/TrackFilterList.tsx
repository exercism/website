import React, { useCallback } from 'react'
import { TrackIcon } from '../../common'

export type Track = {
  slug: string
  title: string
  iconUrl: string
  count: number
  links: {
    exercises: string
  }
}

const TrackFilter = ({
  title,
  iconUrl,
  count,
  checked,
  onChange,
}: Track & {
  checked: boolean
  onChange: (e: React.ChangeEvent) => void
}): JSX.Element => {
  return (
    <label className="c-radio-wrapper">
      <input
        type="radio"
        onChange={onChange}
        checked={checked}
        name="queue_track"
      />
      <div className="row">
        <div className="c-radio" />
        <TrackIcon iconUrl={iconUrl} title={title} />
        <div className="title">{title}</div>
        <div className="count">{count}</div>
      </div>
    </label>
  )
}

export const TrackFilterList = ({
  tracks,
  value,
  setValue,
}: {
  tracks: Track[]
  value: string
  setValue: (value: string) => void
}): JSX.Element => {
  const handleChange = useCallback(
    (e, optionValue) => {
      setValue(optionValue)
    },
    [setValue]
  )

  return (
    <div className="track-filter">
      <h3>Filter by language track</h3>
      <div className="tracks">
        {tracks.map((track) => (
          <TrackFilter
            key={track.slug}
            onChange={(e) => handleChange(e, track.slug)}
            checked={value === track.slug}
            {...track}
          />
        ))}
      </div>
    </div>
  )
}
