import React from 'react'
import { Task, TaskType as TaskTypeProps } from '../../../types'
import { TrackInfo } from './TrackInfo'
import { TaskType } from './TaskType'

export const TrackType = ({
  track,
  type,
}: Partial<Pick<Task, 'track'>> & { type?: TaskTypeProps }): JSX.Element => {
  return (
    <div className="track-type">
      {track ? <TrackInfo track={track} /> : null}
      {type ? <TaskType type={type} /> : null}
    </div>
  )
}
