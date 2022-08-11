import React, { useCallback, useState } from 'react'
import { Pagination } from '../common/Pagination'
import { TrackFilterList } from './queue/TrackFilterList'
import { useTrackList } from './queue/useTrackList'
import { Request } from '../../hooks/request-query'
import { Links } from './Queue'
import { MentoredTrack, MentoredTrackExercise } from '../types'
import { useMentoringQueue } from './queue/useMentoringQueue'
import { Sorter } from './Sorter'
import { SortOption } from './Inbox'

const TRACKS_LIST_CACHE_KEY = 'mentored-tracks'

type AutomationProps = {
  tracksRequest: Request
  links: Links
  defaultTrack: MentoredTrack
  queueRequest: Request
  defaultExercise: MentoredTrackExercise | null
  sortOptions: SortOption[]
}

export function Automation({
  tracksRequest,
  sortOptions,
  links,
  defaultTrack,
  defaultExercise,
  queueRequest,
}: AutomationProps): JSX.Element {
  const [selectedTrack, setSelectedTrack] =
    useState<MentoredTrack>(defaultTrack)

  const [selectedExercise, setSelectedExercise] =
    useState<MentoredTrackExercise | null>(defaultExercise)

  const {
    resolvedData,
    latestData,
    isFetching,
    criteria,
    setCriteria,
    order,
    setOrder,
    page,
    setPage,
    status,
    error,
  } = useMentoringQueue({
    request: queueRequest,
    track: selectedTrack,
    exercise: selectedExercise,
  })

  const handleTrackChange = useCallback(
    (track) => {
      setPage(1)
      setCriteria('')
      setSelectedTrack(track)
    },
    [setPage, setCriteria]
  )

  const {
    tracks,
    status: trackListStatus,
    error: trackListError,
    isFetching: isTrackListFetching,
  } = useTrackList({
    cacheKey: TRACKS_LIST_CACHE_KEY,
    request: tracksRequest,
  })

  return (
    <div className="lg-container">
      <article className="content">
        <div className="c-search-bar">
          <TrackFilterList
            status={trackListStatus}
            error={trackListError}
            tracks={tracks}
            isFetching={isTrackListFetching}
            cacheKey={TRACKS_LIST_CACHE_KEY}
            links={links}
            value={selectedTrack}
            setValue={handleTrackChange}
          />

          <input className="--search" placeholder="Filter by exercise" />
          <Sorter sortOptions={sortOptions} order={order} setOrder={setOrder} />
        </div>
        <Pagination
          setPage={() => console.log('page is set')}
          total={10}
          current={2}
        />
      </article>
    </div>
  )
}
