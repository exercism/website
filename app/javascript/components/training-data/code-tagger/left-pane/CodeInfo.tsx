import React from 'react'
import { TrackIcon, Avatar } from '@/components/common'

export default function CodeInfo({
  track,
  exercise,
}: {
  track: any
  exercise: any
}): JSX.Element {
  return (
    <>
      <TrackIcon
        title={track.title}
        className={'!w-[32px] !h-[32px]'}
        iconUrl={track.iconUrl}
      />
      <div className="student">
        <Avatar src={exercise.iconUrl} />
        <div className="info">
          <div className="exercise">You are assigning tags for</div>
          <div className="handle">
            {exercise.title} in {track.title}
          </div>
        </div>
      </div>
    </>
  )
}
