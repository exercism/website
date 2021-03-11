import React, { useCallback } from 'react'
import { TrackIcon } from '../../common'
import { FetchingBoundary } from '../../FetchingBoundary'
import { MentoredTrack } from '../../types'
import { QueryStatus } from 'react-query'

const TrackFilter = ({
  title,
  iconUrl,
  num_solutions_queued,
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
        <div className="count">{num_solutions_queued}</div>
      </div>
    </label>
  )
}

const DEFAULT_ERROR = new Error('Unable to fetch tracks')

export const TrackFilterList = ({
  status,
  error,
  ...props
}: Props & { status: QueryStatus; error: unknown }): JSX.Element => {
  return (
    <FetchingBoundary
      error={error}
      status={status}
      defaultError={DEFAULT_ERROR}
    >
      <Component {...props} />
    </FetchingBoundary>
  )
}

type Props = {
  tracks: MentoredTrack[] | undefined
  isFetching: boolean
  value: MentoredTrack | null
  setValue: (value: MentoredTrack) => void
}

const Component = ({
  tracks,
  isFetching,
  value,
  setValue,
}: Props): JSX.Element => {
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
              key={track.id}
              onChange={(e) => handleChange(e, track)}
              checked={value?.id === track.id}
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
