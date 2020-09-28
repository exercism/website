import React, { useReducer } from 'react'
import { useRequestQuery } from '../../hooks/request-query'
import { Search } from './TrackList/Search'
import { StatusFilter } from './TrackList/StatusFilter'
import { List } from './TrackList/List'

function reducer(state, action) {
  switch (action.type) {
    case 'criteria.changed':
      return {
        ...state,
        query: { ...state.query, criteria: action.payload.criteria },
      }
    case 'status.changed':
      return {
        ...state,
        query: { ...state.query, status: action.payload.status },
      }
  }
}

export function TrackList({ statusOptions, ...props }) {
  const [request, dispatch] = useReducer(reducer, props.request)
  const { data, isSuccess, isError, isFetching } = useRequestQuery(
    'track-list',
    request
  )

  return (
    <div className="student-track-list">
      <Search dispatch={dispatch} />
      <StatusFilter dispatch={dispatch} options={statusOptions} />
      {isSuccess && <List data={data} />}
      {isFetching && <p>Loading</p>}
      {isError && <p>Something went wrong</p>}
    </div>
  )
}
