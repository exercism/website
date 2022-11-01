import React, { useContext } from 'react'
import { DigDeeperDataContext } from '@/components/track/DigDeeper'
import { TrackIcon, ExerciseIcon } from '../../../common'
type ExerciseTrackIndicatorProps = {
  videoRetrieved: boolean
}

export function ExerciseTrackIndicator({
  videoRetrieved,
}: ExerciseTrackIndicatorProps): JSX.Element {
  const { exercise, track } = useContext(DigDeeperDataContext)

  return (
    <div
      className={`py-8 px-24 bg-gray border-2 border-gradient rounded-100 flex flex-row items-center mb-${
        videoRetrieved ? 16 : 32
      }`}
    >
      <TrackIcon
        iconUrl={track.iconUrl}
        title={track.title}
        className="h-[40px], w-[40px] mr-12"
      />
      <ExerciseIcon iconUrl={exercise.iconUrl} className="h-48 mr-12" />
      <div className="flex flex-col">
        <div className="text-h5">{exercise.title}</div>
        <div className="textColor-6 font-normal leading-150 text-16">
          {track.title}
        </div>
      </div>
    </div>
  )
}
