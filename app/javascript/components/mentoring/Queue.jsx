import React from 'react'
import { SolutionList } from './queue/SolutionList'
import { TextFilter } from './TextFilter'
import { Sorter } from './Sorter'
import { useList } from '../../hooks/use-list'

export function Queue({ sortOptions, ...props }) {
  const { request, setCriteria, setOrder, setPage } = useList(props.request)

  return (
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
  )
}
