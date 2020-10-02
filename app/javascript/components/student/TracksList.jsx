import React, { useReducer } from 'react'
import { useRequestQuery } from '../../hooks/request-query'
import { Search } from './tracks-list/Search'
import { StatusFilter } from './tracks-list/StatusFilter'
import { List } from './tracks-list/List'
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
  const { data, isSuccess, isError, isLoading } = useRequestQuery(
    'track-list',
    request
  )

  return (
    <div className="c-tracks-list">
      <div className="search-bar">
        <div className="md-container">
          <Search dispatch={dispatch} />
        </div>
      </div>
      <div class="md-container">
        <StatusFilter dispatch={dispatch} options={statusOptions} />

        {isLoading && <Loading />}
        {isError && <p>Something went wrong</p>}
        {isSuccess && <List data={data} />}
      </div>
    </div>
  )
}
