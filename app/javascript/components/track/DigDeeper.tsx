import React, { createContext } from 'react'
import type {
  Track,
  Exercise,
  User,
  CommunityVideosProps,
} from '@/components/types'
import {
  Approaches,
  ApproachIntroduction,
  Articles,
  CommunityVideos,
  DiggingDeeper,
} from './dig-deeper-components'
import { DeepDiveVideo } from './dig-deeper-components/DeepDiveVideo'

export type Article = {
  users: User[]
  numAuthors: number
  numContributors: number
  title: string
  blurb: string
  snippetHtml: string
  links: {
    self: string
  }
}

export type Approach = {
  users: User[]
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
  exercise: Exercise & {
    deepDiveYoutubeId: string
    deepDiveBlurb: string
    deepDiveMarkAsSeenEndpoint: string
  }
  links: { video: { create: string; lookup: string } }
}

export const DigDeeperDataContext = createContext<DigDeeperDataContext>(
  {} as DigDeeperDataContext
)

export function DigDeeper({ data }: { data: DigDeeperProps }): JSX.Element {
  return (
    <div className="lg-container grid lg:grid-cols-3 grid-cols-2 gap-40">
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
        <div className="lg:col-span-1 col-span-2">
          <DeepDiveVideo />
          <Approaches approaches={data.approaches} />
          <Articles articles={data.articles} />
        </div>
      </DigDeeperDataContext.Provider>
    </div>
  )
}

export default DigDeeper
