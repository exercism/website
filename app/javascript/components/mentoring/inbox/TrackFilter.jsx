import React from 'react'
import { useIsMounted } from 'use-is-mounted'
import { useRequestQuery } from '../../../hooks/request-query'
import { Loading } from '../../common/Loading'

export function TrackFilter({ request, setTrack }) {
  const isMountedRef = useIsMounted()
  const { isLoading, isError, isSuccess, data } = useRequestQuery(
    'track-filter',
    request,
    isMountedRef
  )

  function handleChange(e) {
    setTrack(e.target.value)
  }

  return (
    <div className="track-filter">
      {isLoading && <Loading />}
      {isError && <p>Something went wrong</p>}
      {isSuccess && (
        <>
          <select
            data-testid="track-filter"
            id="track-filter-track"
            onChange={handleChange}
          >
            <option value={''}>All</option>
            {data.map((track) => {
              return (
                <option key={track.slug} value={track.slug}>
                  {track.title}
                </option>
              )
            })}
          </select>
        </>
      )}
    </div>
  )
}
