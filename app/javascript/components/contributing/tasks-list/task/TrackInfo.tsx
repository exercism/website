import React from 'react'
import { TrackIcon } from '../../../common'
import { Task } from '../../../types'

export const TrackInfo = ({ track }: Pick<Task, 'track'>): JSX.Element => {
  return (
    <div className="track">
      <div className="for">for</div>
      <TrackIcon iconUrl={track.iconUrl} title={track.title} />
      <div className="title">{track.title}</div>
    </div>
  )
}
