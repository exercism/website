import React, { useCallback } from 'react'
import { QueryStatus } from '@tanstack/react-query'
import { APIResponse, Track } from '../TrackSelector'
import { TrackCheckbox } from './TrackCheckbox'
import { FetchingBoundary } from '../../FetchingBoundary'

const NoTracksFoundMessage = () => {
  return <p>No tracks found</p>
}

const TrackOptions = ({
  tracks,
  selected,
  setSelected,
}: {
  tracks: readonly Track[]
  selected: readonly string[]
  setSelected: (selected: string[]) => void
}) => {
  const handleChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>, id: string) => {
      if (e.target.checked) {
        setSelected([...selected, id])
      } else {
        setSelected(selected.filter((v) => v !== id))
      }
    },
    [selected, setSelected]
  )

  return (
    <React.Fragment>
      {tracks.map((track) => {
        return (
          <TrackCheckbox
            key={track.slug}
            {...track}
            checked={selected.includes(track.slug)}
            onChange={(e) => handleChange(e, track.slug)}
          />
        )
      })}
    </React.Fragment>
  )
}

const DEFAULT_ERROR = new Error('Unable to fetch tracks')

export const TracksList = ({
  status,
  error,
  selected,
  setSelected,
  data,
}: {
  status: QueryStatus
  error: Error | unknown
  selected: readonly string[]
  setSelected: (selected: string[]) => void
  data: APIResponse | undefined
}): JSX.Element | null => {
  return (
    <FetchingBoundary
      status={status}
      error={error}
      defaultError={DEFAULT_ERROR}
    >
      {data === undefined || data.tracks.length === 0 ? (
        <NoTracksFoundMessage />
      ) : (
        <TrackOptions
          tracks={data.tracks}
          selected={selected}
          setSelected={setSelected}
        />
      )}
    </FetchingBoundary>
  )
}
