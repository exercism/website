import { ExerciseTrackContext } from '@/components/track/Approaches'
import React, { useContext } from 'react'
import { TrackIcon, ExerciseIcon } from '../../../common'
type ExerciseTrackIndicatorProps = {
  videoRetrieved: boolean
}

export function ExerciseTrackIndicator({
  videoRetrieved,
}: ExerciseTrackIndicatorProps): JSX.Element {
  const { exercise, track } = useContext(ExerciseTrackContext)

  return (
    <div
      className={`py-8 px-24 bg-gray border-2 border-gradient rounded-100 flex flex-row items-center mb-${
        videoRetrieved ? 16 : 32
      }`}
    >
      <TrackIcon
        iconUrl={`https://dg8krxphbh767.cloudfront.net/tracks/${track.slug}.svg`}
        title={track.title}
        className="h-[40px], w-[40px] mr-12"
      />
      <ExerciseIcon
        // TODO: fix this type, and this whole object
        iconUrl={`https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/${exercise.iconName}.svg`}
        className="h-48 mr-12"
      />
      <div className="flex flex-col">
        <div className="text-h5">{exercise.title}</div>
        <div className="textColor-6 font-normal leading-150 text-16">
          {track.title}
        </div>
      </div>
    </div>
  )
}
