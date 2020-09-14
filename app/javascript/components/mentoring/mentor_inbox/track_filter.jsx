import React from 'react'
import { useQuery } from 'react-query'

async function fetchTracks(key, url) {
  const resp = await fetch(url)

  return resp.json()
}

export function TrackFilter({ endpoint, setTrack, value }) {
  const { status, data } = useQuery(['track-filter', endpoint], fetchTracks)

  function handleChange(e) {
    setTrack(e.target.value)
  }

  return (
    <div>
      {status === 'success' && (
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
