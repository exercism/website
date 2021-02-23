import React from 'react'
import { usePaginatedRequestQuery } from '../../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { TracksList } from './choose-track-step/TracksList'

export type APIResponse = {
  tracks: readonly Track[]
}

export type Track = {
  id: string
  title: string
  iconUrl: string
  avgWaitTime: string
  numSolutionsQueued: number
}

export const ChooseTrackStep = ({
  endpoint,
}: {
  endpoint: string
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { status, resolvedData, isFetching } = usePaginatedRequestQuery<
    APIResponse
  >('tracks', { endpoint: endpoint, options: {} }, isMountedRef)

  return (
    <section className="tracks-section">
      <h2>Select the tracks you want to mentor</h2>
      <p>
        This allows us to only show you the solutions you want to mentor.
        <strong>
          Don’t worry, you can change these selections at anytime.
        </strong>
      </p>
      <div className="c-search-bar">
        <input className="--search" />
        {isFetching ? <span>Fetching</span> : null}
        <div className="selected none">No tracks selected</div>
        <button className="btn-cta">
          <span>Continue</span>
        </button>
      </div>
      <div className="tracks">
        <TracksList status={status} data={resolvedData} />
      </div>
    </section>
  )
}
