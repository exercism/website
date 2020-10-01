import React, { useReducer } from 'react'
import { useRequestQuery } from '../../hooks/request-query'
import { Search } from './TracksList/Search'
import { StatusFilter } from './TracksList/StatusFilter'
import { List } from './TracksList/List'
import { Loading } from '../common/Loading'

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

export function TracksList({ statusOptions, ...props }) {
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
      {isFetching && <Loading />}
      {isError && <p>Something went wrong</p>}
    </div>
  )
}
