import React from 'react'
import { SolutionList } from './queue/SolutionList'
import { TextFilter } from './TextFilter'
import { TrackFilterList } from './queue/TrackFilterList'
import { ExerciseFilterList } from './queue/ExerciseFilterList'
import { SolutionCount } from './queue/SolutionCount'
import { Sorter } from './Sorter'
import { useList } from '../../hooks/use-list'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'

export function Queue({ sortOptions, tracks, exercises, ...props }) {
  const isMountedRef = useIsMounted()
  const { request, setCriteria, setOrder, setQuery, setPage } = useList(
    props.request
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
            onResetFilter={() =>
              setQuery({ ...request.query, ...defaultQuery })
            }
          />
        ) : null}
        <TrackFilterList
          tracks={tracks}
          value={request.query.trackSlug}
          setValue={(value) => setQuery({ ...request.query, trackSlug: value })}
        />
        <ExerciseFilterList
          exercises={exercises}
          value={request.query.exerciseSlugs}
          setValue={(value) =>
            setQuery({ ...request.query, exerciseSlugs: value })
          }
        />
      </div>
    </div>
  )
}
