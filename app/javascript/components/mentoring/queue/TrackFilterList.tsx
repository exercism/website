import React, { useCallback } from 'react'
import { GraphicalIcon, TrackIcon } from '../../common'

type Track = {
  slug: string
  title: string
  iconUrl: string
  count: number
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
    <div className="tracks">
      <label className="c-checkbox-wrapper">
        <input type="checkbox" onChange={onChange} checked={checked} />
        <div className="row">
          <div className="c-checkbox">
            <GraphicalIcon icon="checkmark" />
          </div>
          <TrackIcon iconUrl={iconUrl} title={title} />
          <div className="title">{title}</div>
          <div className="count">{count}</div>
        </div>
      </label>
    </div>
  )
}

export const TrackFilterList = ({
  tracks,
  value,
  setValue,
}: {
  tracks: Track[]
  value: string[]
  setValue: (value: string[]) => void
}): JSX.Element => {
  const handleChange = useCallback(
    (e, optionValue) => {
      if (e.target.checked) {
        setValue([...value, optionValue])
      } else {
        setValue(value.filter((v) => v !== optionValue))
      }
    },
    [setValue, value]
  )

  return (
    <div className="mentor-queue-filtering">
      <div className="track-filter">
        <h3>Filter by language track</h3>
        {tracks.map((track) => (
          <TrackFilter
            key={track.slug}
            onChange={(e) => handleChange(e, track.slug)}
            checked={value.includes(track.slug)}
            {...track}
          />
        ))}
      </div>
    </div>
  )
}
