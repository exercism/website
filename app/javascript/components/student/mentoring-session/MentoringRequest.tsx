import React from 'react'
import { MentoringRequestForm } from './mentoring-request/MentoringRequestForm'
import { MentoringRequestInfo } from './mentoring-request/MentoringRequestInfo'
import {
  Iteration,
  MentorSessionRequest as Request,
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
} from '../../types'
import { Video } from '../MentoringSession'

type Links = {
  learnMoreAboutPrivateMentoring: string
  privateMentoring: string
  mentoringGuide: string
  createMentorRequest: string
}

export const MentoringRequest = ({
  isFirstTimeOnTrack,
  track,
  exercise,
  request,
  latestIteration,
  videos,
  links,
  onCreate,
}: {
  isFirstTimeOnTrack: boolean
  track: Track
  exercise: Exercise
  request?: Request
  latestIteration: Iteration
  videos: Video[]
  links: Links
  onCreate: (mentorRequest: Request) => void
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
      onSuccess={onCreate}
      links={links}
    />
  )
}
