import React, { createContext } from 'react'
import type {
  Track,
  Exercise,
  User,
  CommunityVideosProps,
} from '@/components/types'
import {
  ApproachExamples,
  ApproachIntroduction,
  CommunityVideos,
  DiggingDeeper,
} from './approaches-elements'

type ApproachUser = Pick<User, 'avatarUrl' | 'handle'> & {
  name: string
  links: {
    profile: string | null
  }
}
export type Approach = {
  users: ApproachUser[]
  numAuthors: number
  numContributors: number
  title: string
  blurb: string
  snippet: string
  links: {
    self: string
  }
}

export type ApproachesProps = {
  introduction: ApproachIntroduction
  approaches: Approach[]
} & ApproachesDataContext &
  CommunityVideosProps

type ApproachesDataContext = {
  track: Track
  exercise: Exercise
  links: { video: { create: string; lookup: string } }
}

export const ApproachesDataContext = createContext<ApproachesDataContext>(
  {} as ApproachesDataContext
)

export function Approaches({ data }: { data: ApproachesProps }): JSX.Element {
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
          <ApproachExamples approaches={data.approaches} />
        </div>
      </ApproachesDataContext.Provider>
    </div>
  )
}
