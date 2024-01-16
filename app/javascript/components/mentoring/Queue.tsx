import React, { useState, useEffect, useRef, useCallback } from 'react'
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

export default function Queue({
  queueRequest,
  tracksRequest,
  defaultTrack,
  defaultExercise,
  sortOptions,
  links,
}: {
  queueRequest: Request
  tracksRequest: Request
  defaultTrack: MentoredTrack
  defaultExercise: MentoredTrackExercise | null
  sortOptions: SortOption[]
  links: Links
}): JSX.Element {
  const isMounted = useRef(false)
  const {
    tracks,
    status: trackListStatus,
    error: trackListError,
    isFetching: isTrackListFetching,
  } = useTrackList({
    cacheKey: [TRACKS_LIST_CACHE_KEY],
    request: tracksRequest,
  })
  const [selectedTrack, setSelectedTrack] =
    useState<MentoredTrack>(defaultTrack)
  const {
    exercises,
    status: exerciseListStatus,
    error: exerciseListError,
  } = useExerciseList({ track: selectedTrack })
  const [selectedExercise, setSelectedExercise] =
    useState<MentoredTrackExercise | null>(defaultExercise)
  const {
    resolvedData,
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

  useEffect(() => {
    if (tracks.length === 0) {
      return
    }

    if (tracks.find((track) => track.slug === selectedTrack.slug)) {
      return
    }

    setSelectedTrack(tracks[0])
  }, [selectedTrack.slug, tracks])

  useEffect(() => {
    if (!isMounted.current) {
      isMounted.current = true
      return
    }

    setSelectedExercise(null)
  }, [selectedTrack])

  const handleExerciseChange = useCallback(
    (exercise) => {
      setPage(1)
      setCriteria('')
      setSelectedExercise(exercise)
    },
    [setPage, setCriteria]
  )

  const handleTrackChange = useCallback(
    (track) => {
      setPage(1)
      setCriteria('')
      setSelectedTrack(track)
    },
    [setPage, setCriteria]
  )

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
            setPage={setPage}
            setOrder={setOrder}
          />
        </header>
        <ResultsZone isFetching={isFetching}>
          <SolutionList
            status={status}
            error={error}
            page={page}
            resolvedData={resolvedData}
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
          setValue={handleTrackChange}
          cacheKey={[TRACKS_LIST_CACHE_KEY]}
          links={links}
        />
        <ExerciseFilterList
          status={exerciseListStatus}
          exercises={exercises}
          value={selectedExercise}
          setValue={handleExerciseChange}
          error={exerciseListError}
        />
      </div>
    </div>
  )
}
