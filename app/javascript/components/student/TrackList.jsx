import React from 'react'
import { TrackIcon } from '../common/TrackIcon'
import { useRequestQuery } from '../../hooks/request-query'

export function TrackList({ request }) {
  const { data, isSuccess } = useRequestQuery('track-list', request)

  return (
    <div>
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
