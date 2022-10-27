import React, { createContext } from 'react'
import { Track, Exercise, User } from '../types'
import {
  Approaches,
  ApproachIntroduction,
  Articles,
  CommunityVideos,
  DiggingDeeper,
} from './approaches-elements'
import { CommunityVideosProps } from './approaches-elements/community-videos/types'

type DigDeeperUser = Pick<User, 'avatarUrl' | 'handle'> & {
  name: string
  links: {
    profile: string | null
  }
}

export type Article = {
  users: DigDeeperUser[]
  numAuthors: number
  numContributors: number
  title: string
  blurb: string
  snippet: string
  links: {
    self: string
  }
}

export type Approach = {
  users: DigDeeperUser[]
  numAuthors: number
  numContributors: number
  title: string
  blurb: string
  snippet: string
  links: {
    self: string
  }
}

export type DigDeeperProps = {
  introduction: ApproachIntroduction
  approaches: Approach[]
  articles: Article[]
} & DigDeeperDataContext &
  CommunityVideosProps

type DigDeeperDataContext = {
  track: Track
  exercise: Exercise
  links: { video: { create: string; lookup: string } }
}

export const DigDeeperDataContext = createContext<DigDeeperDataContext>(
  {} as DigDeeperDataContext
)

export function DigDeeper({ data }: { data: DigDeeperProps }): JSX.Element {
  return (
    <div className="lg-container grid grid-cols-3 gap-40">
      <DigDeeperDataContext.Provider
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
          <Approaches approaches={data.approaches} />
          <Articles articles={data.articles} />
        </div>
      </DigDeeperDataContext.Provider>
    </div>
  )
}
