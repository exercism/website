import React, { useCallback, useMemo } from 'react'
import { SolutionList } from './queue/SolutionList'
import { TextFilter } from './TextFilter'
import { TrackFilterList } from './queue/TrackFilterList'
import { Sorter } from './Sorter'
import { useList } from '../../hooks/use-list'

export function Queue({ sortOptions, tracks, ...props }) {
  const { request, setCriteria, setOrder, setFilter, setPage } = useList(
    props.request
  )
  const filterValue = useMemo(() => request.query.filter || { track: [] }, [
    request.query.filter,
  ])
  const setTrackFilter = useCallback(
    (value) => {
      setFilter({ ...filterValue, track: value })
    },
    [filterValue, setFilter]
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
        <SolutionList request={request} setPage={setPage} />
      </div>
      <TrackFilterList
        tracks={tracks}
        value={filterValue.track}
        setValue={setTrackFilter}
      />
    </div>
  )
}
