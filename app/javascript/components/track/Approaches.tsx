import React, { createContext } from 'react'
import { Track, Exercise } from '../types'
import {
  ApproachExamples,
  ApproachIntroduction,
  CommunityVideos,
  DiggingDeeper,
} from './approaches-elements'
import { CommunityVideosProps } from './approaches-elements/community-videos/types'

export type ApproachesProps = {
  data: {
    introduction: ApproachIntroduction
  } & ApproachesDataContext &
    CommunityVideosProps
}

type ApproachesDataContext = {
  track: Track
  exercise: Exercise
  links: { video: { create: string; lookup: string } }
}

export const ApproachesDataContext = createContext<ApproachesDataContext>(
  {} as ApproachesDataContext
)

export function Approaches({ data }: ApproachesProps): JSX.Element {
  return (
    <div className="lg-container grid grid-cols-3 gap-40">
      <ApproachesDataContext.Provider
        value={{
          exercise: data.exercise,
          track: data.track,
          links: data.links,
        }}
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
