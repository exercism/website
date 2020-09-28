import React, { useReducer } from 'react'
import { TrackIcon } from '../common/TrackIcon'
import { Search } from './TrackList/Search'
import { useRequestQuery } from '../../hooks/request-query'

function reducer(state, action) {
  switch (action.type) {
    case 'criteria.changed':
      return {
        ...state,
        query: { ...state.query, criteria: action.payload.criteria },
      }
  }
}

export function TrackList(props) {
  const [request, dispatch] = useReducer(reducer, props.request)
  const { data, isSuccess } = useRequestQuery('track-list', request)

  return (
    <div className="student-track-list">
      <Search dispatch={dispatch} />
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
              return (
                <tr key={track.id}>
                  <td>
                    <TrackIcon track={track} />
                  </td>
                  <td>{track.title}</td>
                  <td>{track.numConceptExercises}</td>
                  <td>{track.numPracticeExercises}</td>
                  <td>{track.webUrl}</td>
                  <td>{track.isNew.toString()}</td>
                  <td>{track.tags.join(', ')}</td>
                  <td>{track.isJoined.toString()}</td>
                  <td>{track.numCompletedConceptExercises}</td>
                  <td>{track.numCompletedPracticeExercises}</td>
                </tr>
              )
            })}
          </tbody>
        </table>
      )}
    </div>
  )
}
