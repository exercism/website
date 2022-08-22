import React from 'react'
import { TrackIcon, Avatar } from '../../../common'

export default function RepresentationInfo({
  track,
  exercise,
}: {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  track: any
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
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
          <div className="exercise">
            You’re giving feedback on a solution set for
          </div>
          <div className="handle">
            {exercise.title} in {track.title}
          </div>
        </div>
      </div>
    </>
  )
}
