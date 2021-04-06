import React, { useState, useCallback, useEffect } from 'react'
import { useTrackList } from './queue/useTrackList'
import { useExerciseList } from './queue/useExerciseList'
import { MentoredTrack, MentoredTrackExercise } from '../types'
import { useMentoringQueue } from './queue/useMentoringQueue'
import { TrackFilterList } from './queue/TrackFilterList'
import { Request } from '../../hooks/request-query'
import { ExerciseFilterList } from './queue/ExerciseFilterList'
import { SolutionList } from './queue/SolutionList'
import { TextFilter } from './TextFilter'
import { Sorter } from './Sorter'
import { ResultsZone } from '../ResultsZone'

const TRACKS_LIST_CACHE_KEY = 'mentored-tracks'

type SortOption = {
  value: string
  label: string
}

export type Links = {
  tracks: string
  updateTracks: string
}

export const Queue = ({
  queueRequest,
  tracksRequest,
  defaultTrack,
  sortOptions,
  links,
}: {
  queueRequest: Request
  tracksRequest: Request
  defaultTrack: MentoredTrack
  sortOptions: SortOption[]
  links: Links
}): JSX.Element => {
  const {
    tracks,
    status: trackListStatus,
    error: trackListError,
    isFetching: isTrackListFetching,
  } = useTrackList({
    cacheKey: TRACKS_LIST_CACHE_KEY,
    request: tracksRequest,
  })
  const [selectedTrack, setSelectedTrack] = useState<MentoredTrack | null>(
    defaultTrack
  )
  const {
    exercises,
    status: exerciseListStatus,
    error: exerciseListError,
  } = useExerciseList({ track: selectedTrack })
  const [
    selectedExercise,
    setSelectedExercise,
  ] = useState<MentoredTrackExercise | null>(null)
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

  const handleReset = useCallback(() => {
    setSelectedTrack(tracks[0])
    setSelectedExercise(null)
  }, [tracks])

  useEffect(() => {
    {
      /* TODO: This is overriding whatever is passed as the defaultTrack */
    }
    setSelectedTrack(tracks[0])
  }, [tracks])

  useEffect(() => {
    setSelectedExercise(null)
  }, [selectedTrack])

  return (
    <div className="queue-section-content">
      <div className="c-mentor-queue">
        <header className="c-search-bar">
          <TextFilter
            filter={criteria}
            setFilter={setCriteria}
            id="mentoring-queue-student-name-filter"
            placeholder="Filter by student handle"
          />
          <Sorter
            sortOptions={sortOptions}
            order={order}
            setOrder={setOrder}
            id="mentoring-queue-sorter"
          />
        </header>
        <ResultsZone isFetching={isFetching}>
          <SolutionList
            status={status}
            error={error}
            page={page}
            resolvedData={resolvedData}
            latestData={latestData}
            setPage={setPage}
          />
        </ResultsZone>
      </div>
      <div className="mentor-queue-filtering">
        <TrackFilterList
          status={trackListStatus}
          error={trackListError}
          tracks={tracks}
          isFetching={isTrackListFetching}
          value={selectedTrack}
          setValue={setSelectedTrack}
          cacheKey={TRACKS_LIST_CACHE_KEY}
          total={resolvedData?.meta.totalCount}
          links={links}
        />
        <ExerciseFilterList
          status={exerciseListStatus}
          exercises={exercises}
          value={selectedExercise}
          setValue={setSelectedExercise}
          error={exerciseListError}
        />
      </div>
    </div>
  )
}
