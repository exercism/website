import React from 'react'
import { Track } from './TrackList/Track'
import { useList } from '../hooks/use_list'
import { useRequestQuery } from '../hooks/request_query'

export function TrackList(props) {
  const [request, setFilter, setSort, setPage] = useList(props.request)
  const { status, data } = useRequestQuery('track-list', request)

  return (
    <div>
      <table>
        <thead>
          <tr>
            <th>Track icon</th>
            <th>Track title</th>
            <th>Exercise count</th>
            <th>Concept exercise count</th>
            <th>Practice exercise count</th>
            <th>Student count</th>
            <th>New?</th>
            <th>Joined?</th>
            <th>Tags</th>
            <th>Completed exercise count</th>
            <th>Progress %</th>
            <th>URL</th>
          </tr>
        </thead>
        <tbody>
          {data.map((track) => {
            return <Track key={track.id} {...track} />
          })}
        </tbody>
      </table>
    </div>
  )
}
