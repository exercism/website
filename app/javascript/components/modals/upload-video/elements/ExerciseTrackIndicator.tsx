import React from 'react'
import { TrackIcon, ExerciseIcon } from '../../../common'
type ExerciseTrackIndicatorProps = {
  exercise: string
  exerciseIconUrl: string
  track: string
  trackIconUrl: string
}

export function ExerciseTrackIndicator({
  exercise,
  exerciseIconUrl,
  track,
  trackIconUrl,
}: ExerciseTrackIndicatorProps): JSX.Element {
  return (
    <div className="py-8 px-24 bg-gray border-2 border-gradient rounded-100 flex flex-row items-center mb-32">
      <TrackIcon
        iconUrl={trackIconUrl}
        title={track}
        className="h-[40px], w-[40px] mr-12"
      />
      <ExerciseIcon iconUrl={exerciseIconUrl} className="h-48 mr-12" />
      <div className="flex flex-col">
        <div className="text-h5">{exercise}</div>
        <div className="textColor-6 font-normal leading-150 text-16">Rust</div>
      </div>
    </div>
  )
}
