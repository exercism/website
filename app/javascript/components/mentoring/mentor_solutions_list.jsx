import React, { useReducer, useCallback } from 'react'
import { SolutionList } from './mentor_solutions_list/solution_list'
import { TextFilter } from './text_filter'

function reducer(state, action) {
  switch (action.type) {
    case 'page.changed':
      return { ...state, query: { ...state.query, page: action.payload.page } }
    case 'filter.changed':
      return {
        ...state,
        query: { ...state.query, filter: action.payload.filter, page: 1 },
      }
    default:
      if (process.env.NODE_ENV === 'development') {
        throw new Error(`Unknown action type: ${action.type}`)
      }
      return state
  }
}

export function MentorSolutionsList(props) {
  const [request, dispatch] = useReducer(
    reducer,
    Object.assign({ query: { page: 1 } }, props.request)
  )

  const setFilter = useCallback(
    (filter) => {
      dispatch({ type: 'filter.changed', payload: { filter: filter } })
    },
    [dispatch]
  )

  const setPage = useCallback(
    (page) => {
      dispatch({ type: 'page.changed', payload: { page: page } })
    },
    [dispatch]
  )

  return (
    <div className="mentor-solutions-list">
      <TextFilter
        filter={request.query.filter}
        setFilter={setFilter}
        id="mentor-conversations-list-student-name-filter"
        placeholder="Filter by student name"
      />
      <SolutionList request={request} setPage={setPage} />
    </div>
  )
}
