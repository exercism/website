import React, { createContext } from 'react'
import { Track, Exercise } from '../types'
import {
  ApproachExamples,
  ApproachIntroduction,
  CommunityVideos,
  CommunityVideosProps,
  DiggingDeeper,
} from './approaches-elements'

export type ApproachesProps = {
  data: {
    introduction: ApproachIntroduction
  } & ExerciseTrackContext &
    CommunityVideosProps
}

type ExerciseTrackContext = {
  track: Track
  exercise: Exercise
}

export const ExerciseTrackContext = createContext<ExerciseTrackContext>(
  {} as ExerciseTrackContext
)

export function Approaches({ data }: ApproachesProps): JSX.Element {
  return (
    <div className="lg-container grid grid-cols-3 gap-40">
      <ExerciseTrackContext.Provider
        value={{ exercise: data.exercise, track: data.track }}
      >
        <div className="col-span-2">
          <DiggingDeeper introduction={data.introduction} />
          <CommunityVideos videos={data.videos} />
        </div>
        <div className="col-span-1">
          <ApproachExamples />
        </div>
      </ExerciseTrackContext.Provider>
    </div>
  )
}
