import React, { useMemo } from 'react'
import { SolutionList } from './queue/SolutionList'
import { TextFilter } from './TextFilter'
import { TrackFilterList } from './queue/TrackFilterList'
import { ExerciseFilterList } from './queue/ExerciseFilterList'
import { SolutionCount } from './queue/SolutionCount'
import { Sorter } from './Sorter'
import { useList } from '../../hooks/use-list'
import {
  useRequestQuery,
  usePaginatedRequestQuery,
} from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { Loading } from '../common'

export function Queue({ sortOptions, tracks, ...props }) {
  const isMountedRef = useIsMounted()
  const defaultQuery = props.request.query
  const { request, setCriteria, setOrder, setQuery, setPage } = useList(
    props.request
  )
  const track = useMemo(
    () => tracks.find((track) => request.query.trackSlug === track.slug),
    [request.query.trackSlug, tracks]
  )
  const { data: exercises, status: exercisesFetchStatus } = useRequestQuery(
    ['exercises', track.slug],
    {
      endpoint: track.links.exercises,
      options: {
        initialData:
          request.query === defaultQuery ? props.exercises : undefined,
      },
    },
    isMountedRef
  )
  const { status, resolvedData, latestData } = usePaginatedRequestQuery(
    'mentor-solutions-list',
    request,
    isMountedRef
  )

  return (
    <div className="queue-section-content">
      <div className="c-mentor-queue">
        <header className="c-search-bar">
          <TextFilter
            filter={request.query.criteria}
            setFilter={setCriteria}
            id="mentoring-queue-student-name-filter"
            placeholder="Filter by student name"
          />
          <Sorter
            sortOptions={sortOptions}
            order={request.query.order}
            setOrder={setOrder}
            id="mentoring-queue-sorter"
          />
        </header>
        <SolutionList
          status={status}
          page={request.query.page}
          resolvedData={resolvedData}
          latestData={latestData}
          setPage={setPage}
        />
      </div>
      <div className="mentor-queue-filtering">
        {resolvedData ? (
          <SolutionCount
            unscopedTotal={resolvedData.meta.unscopedTotal}
            total={resolvedData.meta.total}
            onResetFilter={() => setQuery(defaultQuery)}
          />
        ) : null}
        <TrackFilterList
          tracks={tracks}
          value={request.query.trackSlug}
          setValue={(value) =>
            setQuery({ ...request.query, trackSlug: value, exerciseSlugs: [] })
          }
        />
        {exercisesFetchStatus === 'loading' ? <Loading /> : null}
        {exercisesFetchStatus === 'success' ? (
          <ExerciseFilterList
            exercises={exercises}
            value={request.query.exerciseSlugs}
            setValue={(value) =>
              setQuery({ ...request.query, exerciseSlugs: value })
            }
          />
        ) : null}
      </div>
    </div>
  )
}
