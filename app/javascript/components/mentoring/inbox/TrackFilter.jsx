import React from 'react'
import { useRequestQuery } from '../../../hooks/request-query'
import { Loading } from '../../common/Loading'

export function TrackFilter({ request, setTrack }) {
  const { isLoading, isError, isSuccess, data } = useRequestQuery(
    'track-filter',
    request
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
          <label htmlFor="track-filter-track">Track</label>
          <select id="track-filter-track" onChange={handleChange}>
            <option value={''}>All</option>
            {data.map((track) => {
              return (
                <option key={track.id} value={track.id}>
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
