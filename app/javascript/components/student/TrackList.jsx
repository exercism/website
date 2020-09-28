import React, { useReducer } from 'react'
import { Search } from './TrackList/Search'
import { StatusFilter } from './TrackList/StatusFilter'
import { Track } from './TrackList/Track'
import { useRequestQuery } from '../../hooks/request-query'

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
  const { data, isSuccess } = useRequestQuery('track-list', request)

  return (
    <div className="student-track-list">
      <Search dispatch={dispatch} />
      <StatusFilter dispatch={dispatch} options={statusOptions} />
      {isSuccess && (
        <table>
          <thead>
            <tr>
              <th>Icon</th>
              <th>Title</th>
              <th>Num concept exercises</th>
              <th>Num practice exercises</th>
              <th>URL</th>
              <th>New?</th>
              <th>Tags</th>
              <th>Joined?</th>
              <th>Num completed concept exercises</th>
              <th>Num completed practice exercises</th>
            </tr>
          </thead>
          <tbody>
            {data.tracks.map((track) => {
              return <Track key={track.id} track={track} />
            })}
          </tbody>
        </table>
      )}
    </div>
  )
}
