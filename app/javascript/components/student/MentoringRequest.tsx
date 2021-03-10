import React from 'react'
import { MentoringRequestForm } from './mentoring-request/MentoringRequestForm'
import { MentoringRequestInfo } from './mentoring-request/MentoringRequestInfo'
import { Iteration, MentoringRequest as MentoringRequestProps } from '../types'

export type Track = {
  title: string
  medianWaitTime: string
}

export type Exercise = {
  title: string
}

export type Links = {
  learnMoreAboutPrivateMentoring: string
  privateMentoring: string
  mentoringGuide: string
}

export type Video = {
  url: string
  title: string
  date: string
}

export const MentoringRequest = ({
  isFirstTimeOnTrack,
  track,
  exercise,
  request,
  latestIteration,
  videos,
  links,
}: {
  isFirstTimeOnTrack: boolean
  track: Track
  exercise: Exercise
  request?: MentoringRequestProps
  latestIteration: Iteration
  videos: Video[]
  links: Links
}): JSX.Element => {
  return request ? (
    <MentoringRequestInfo
      request={request}
      links={links}
      track={track}
      videos={videos}
      iteration={latestIteration}
    />
  ) : (
    <MentoringRequestForm
      isFirstTimeOnTrack={isFirstTimeOnTrack}
      track={track}
      exercise={exercise}
      links={links}
    />
  )
}
