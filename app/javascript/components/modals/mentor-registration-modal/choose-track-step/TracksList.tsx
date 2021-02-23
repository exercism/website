import React, { useCallback } from 'react'
import { QueryStatus } from 'react-query'
import { APIResponse } from '../ChooseTrackStep'
import { Loading } from '../../../common'
import { TrackCheckbox } from './TrackCheckbox'

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
    <FetchingBoundary status={status}>
      {data === undefined || data.tracks.length === 0 ? (
        <p>No tracks found</p>
      ) : (
        data.tracks.map((track) => {
          return (
            <TrackCheckbox
              key={track.id}
              {...track}
              checked={selected.includes(track.id)}
              onChange={(e) => handleChange(e, track.id)}
            />
          )
        })
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
