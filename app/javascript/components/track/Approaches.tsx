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
  } & ApproachesDataContext &
    CommunityVideosProps
}

type ApproachesDataContext = {
  track: Track
  exercise: Exercise
}

export const ApproachesDataContext = createContext<ApproachesDataContext>(
  {} as ApproachesDataContext
)

export function Approaches({ data }: ApproachesProps): JSX.Element {
  console.log(data)
  return (
    <div className="lg-container grid grid-cols-3 gap-40">
      <ApproachesDataContext.Provider
        value={{ exercise: data.exercise, track: data.track }}
      >
        <div className="col-span-2">
          <DiggingDeeper introduction={data.introduction} />
          <CommunityVideos videos={data.videos} />
        </div>
        <div className="col-span-1">
          <ApproachExamples />
        </div>
      </ApproachesDataContext.Provider>
    </div>
  )
}
