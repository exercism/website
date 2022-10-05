import React, { createContext } from 'react'
import { Icon } from '../common'
import { Track, Exercise } from '../types'
import {
  ApproachExamples,
  ApproachIntroduction,
  CommunityVideos,
  CommunityVideosProps,
  DiggingDeeper,
  NoContentYet,
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
  links: { video: { create: string; lookup: string } }
}

export const ApproachesDataContext = createContext<ApproachesDataContext>(
  {} as ApproachesDataContext
)

export function Approaches({ data }: ApproachesProps): JSX.Element {
  console.log(data)
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
          {data.introduction.html.length > 0 ? (
            <DiggingDeeper introduction={data.introduction} />
          ) : (
            <NoContentYet
              exerciseTitle={data.exercise.title}
              contentType={'Introduction notes'}
            >
              Want to contribute?&nbsp;
              <a className="flex" href={data.introduction.links.new}>
                <span className="underline">You can do it here.</span>&nbsp;
                <Icon
                  className="filter-textColor6"
                  icon={'new-tab'}
                  alt={'open in a new tab'}
                />
              </a>
            </NoContentYet>
          )}
          <CommunityVideos videos={data.videos} />
        </div>
        <div className="col-span-1">
          <ApproachExamples />
        </div>
      </ApproachesDataContext.Provider>
    </div>
  )
}
