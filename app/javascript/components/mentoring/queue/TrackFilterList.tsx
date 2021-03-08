import React, { useCallback } from 'react'
import { TrackIcon } from '../../common'
import { MentoredTrack } from './useTrackList'

const TrackFilter = ({
  title,
  iconUrl,
  count,
  checked,
  onChange,
}: MentoredTrack & {
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
  isFetching,
  value,
  setValue,
}: {
  tracks: MentoredTrack[] | undefined
  isFetching: boolean
  value: MentoredTrack | null
  setValue: (value: MentoredTrack) => void
}): JSX.Element => {
  const handleChange = useCallback(
    (e, optionValue) => {
      setValue(optionValue)
    },
    [setValue]
  )

  return (
    <div className="track-filter">
      {isFetching ? <span>Fetching</span> : null}
      <h3>Filter by language track</h3>
      {tracks && tracks.length > 0 ? (
        <div className="tracks">
          {tracks.map((track) => (
            <TrackFilter
              key={track.slug}
              onChange={(e) => handleChange(e, track)}
              checked={value?.slug === track.slug}
              {...track}
            />
          ))}
        </div>
      ) : (
        <p>No tracks found</p>
      )}
    </div>
  )
}
