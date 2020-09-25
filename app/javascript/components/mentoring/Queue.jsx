import React from 'react'
import { SolutionList } from './Queue/SolutionList'
import { TextFilter } from './TextFilter'
import { Sorter } from './Sorter'
import { useList } from '../../hooks/use-list'

export function Queue({ sortOptions, ...props }) {
  const [request, setFilter, setSort, setPage] = useList(props.request)

  return (
    <div className="mentoring-queue">
      <TextFilter
        filter={request.query.filter}
        setFilter={setFilter}
        id="mentoring-queue-student-name-filter"
        placeholder="Filter by student name"
      />
      <Sorter
        sortOptions={sortOptions}
        sort={request.query.sort}
        setSort={setSort}
        id="mentoring-queue-sorter"
      />
      <SolutionList request={request} setPage={setPage} />
    </div>
  )
}
