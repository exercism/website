import React from 'react'
import { useIsMounted } from 'use-is-mounted'
import { useRequestQuery } from '../../../hooks/request-query'
import { Loading } from '../../common/Loading'
import { TrackList } from './TrackList'

export function TrackFilter({ request, value, setTrack }) {
  const isMountedRef = useIsMounted()
  const { isLoading, isError, isSuccess, data: tracks } = useRequestQuery(
    'track-filter',
    request,
    isMountedRef
  )
  return (
    <div className="track-filter">
      {isLoading && <Loading />}
      {isError && <p>Something went wrong</p>}
      {isSuccess && (
        <TrackList tracks={tracks} setTrack={setTrack} value={value} />
      )}
    </div>
  )
}
