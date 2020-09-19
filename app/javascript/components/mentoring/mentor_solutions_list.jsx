import React from 'react'
import { SolutionList } from './mentor_solutions_list/solution_list'
import { TextFilter } from './text_filter'
import { Sorter } from './sorter'
import { useList } from '../../hooks/use_list'

export function MentorSolutionsList(props) {
  const [request, setFilter, setSort, setPage] = useList(props.request)

  return (
    <div className="mentor-solutions-list">
      <TextFilter
        filter={request.query.filter}
        setFilter={setFilter}
        id="mentor-conversations-list-student-name-filter"
        placeholder="Filter by student name"
      />
      <Sorter
        sort={request.query.sort}
        setSort={setSort}
        id="mentor-conversations-list-sorter"
      />
      <SolutionList request={request} setPage={setPage} />
    </div>
  )
}
