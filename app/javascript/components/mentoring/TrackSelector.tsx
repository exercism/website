import React, { useCallback } from 'react'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { TracksList } from './track-selector/TracksList'
import { SelectedTracksMessage } from './track-selector/SelectedTracksMessage'
import { ContinueButton } from './track-selector/ContinueButton'
import { SearchBar } from './track-selector/SearchBar'
import { useList } from '../../hooks/use-list'
import { ResultsZone } from '../ResultsZone'

export type APIResponse = {
  tracks: readonly Track[]
}

export type Track = {
  slug: string
  title: string
  iconUrl: string
  medianWaitTime: number
  numSolutionsQueued: number
}

export const TrackSelector = ({
  tracksEndpoint,
  selected,
  setSelected,
  onContinue,
}: {
  tracksEndpoint: string
  selected: string[]
  setSelected: (selected: string[]) => void
  onContinue: () => void
}): JSX.Element => {
  const { request, setCriteria } = useList({
    endpoint: tracksEndpoint,
    options: {},
  })
  const {
    status,
    data: resolvedData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<APIResponse>(
    ['tracks', request.endpoint, request.query],
    request
  )

  const handleContinue = useCallback(() => {
    onContinue()
  }, [onContinue])

  return (
    <div className="c-mentor-track-selector">
      <div className="c-search-bar">
        <SearchBar
          value={request.query.criteria || ''}
          setValue={setCriteria}
        />
        <SelectedTracksMessage numSelected={selected.length} />
        <ContinueButton
          disabled={selected.length === 0}
          onClick={handleContinue}
        />
      </div>
      <ResultsZone isFetching={isFetching}>
        <div className="tracks">
          <TracksList
            status={status}
            selected={selected}
            setSelected={setSelected}
            data={resolvedData}
            error={error}
          />
        </div>
      </ResultsZone>
    </div>
  )
}
