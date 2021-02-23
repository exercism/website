import React, { useCallback } from 'react'
import { QueryStatus } from 'react-query'
import { APIResponse, Track } from '../ChooseTrackStep'
import { Loading } from '../../../common'
import { TrackCheckbox } from './TrackCheckbox'

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
            key={track.id}
            {...track}
            checked={selected.includes(track.id)}
            onChange={(e) => handleChange(e, track.id)}
          />
        )
      })}
    </React.Fragment>
  )
}

export const TracksList = ({
  status,
  selected,
  setSelected,
  data,
}: {
  status: QueryStatus
  selected: readonly string[]
  setSelected: (selected: string[]) => void
  data: APIResponse | undefined
}): JSX.Element | null => {
  return (
    <FetchingBoundary status={status}>
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

const FetchingBoundary = ({
  status,
  children,
  LoadingComponent = Loading,
}: React.PropsWithChildren<{
  status: QueryStatus
  LoadingComponent?: React.ComponentType
}>) => {
  switch (status) {
    case 'loading':
      return <LoadingComponent />
    case 'success': {
      return <React.Fragment>{children}</React.Fragment>
    }
    default:
      return null
  }
}
