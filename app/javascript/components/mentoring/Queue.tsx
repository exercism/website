import React, { useState, useCallback } from 'react'
import { useTrackList, MentoredTrack } from './queue/useTrackList'
import { useExerciseList, MentoredTrackExercise } from './queue/useExerciseList'
import { useMentoringQueue } from './queue/useMentoringQueue'
import { TrackFilterList } from './queue/TrackFilterList'
import { Request } from '../../hooks/request-query'
import { SolutionCount } from './queue/SolutionCount'
import { ExerciseFilterList } from './queue/ExerciseFilterList'
import { SolutionList } from './queue/SolutionList'
import { TextFilter } from './TextFilter'
import { Sorter } from './Sorter'
import { ChangeTracksButton } from './queue/ChangeTracksButton'

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
  const [selectedExercises, setSelectedExercises] = useState<
    MentoredTrackExercise[]
  >([])
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
    exercises: selectedExercises,
  })

  const handleReset = useCallback(() => {
    setSelectedTrack(defaultTrack)
    setSelectedExercises([])
  }, [defaultTrack])

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
          {isFetching ? <span>Fetching...</span> : null}
          <Sorter
            sortOptions={sortOptions}
            order={order}
            setOrder={setOrder}
            id="mentoring-queue-sorter"
          />
        </header>
        <SolutionList
          status={status}
          error={error}
          page={page}
          resolvedData={resolvedData}
          latestData={latestData}
          setPage={setPage}
        />
      </div>
      <div className="mentor-queue-filtering">
        <ChangeTracksButton links={links} cacheKey={TRACKS_LIST_CACHE_KEY} />
        {resolvedData ? (
          <SolutionCount
            unscopedTotal={resolvedData.meta.unscopedTotal}
            total={resolvedData.meta.totalCount}
            onResetFilter={handleReset}
          />
        ) : null}
        <TrackFilterList
          status={trackListStatus}
          error={trackListError}
          tracks={tracks}
          isFetching={isTrackListFetching}
          value={selectedTrack}
          setValue={setSelectedTrack}
        />
        <div className="exercise-filter">
          <h3>Filter by exercise</h3>
          <ExerciseFilterList
            status={exerciseListStatus}
            exercises={exercises}
            value={selectedExercises}
            setValue={setSelectedExercises}
            error={exerciseListError}
          />
        </div>
      </div>
    </div>
  )
}
