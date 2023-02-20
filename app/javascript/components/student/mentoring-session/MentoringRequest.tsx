import React from 'react'
import { MentoringRequestForm } from './mentoring-request/MentoringRequestForm'
import { MentoringRequestInfo } from './mentoring-request/MentoringRequestInfo'
import {
  Iteration,
  MentorSessionRequest as Request,
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
  DiscussionLinks,
} from '@/components/types'
import { Video } from '../MentoringSession'

export const MentoringRequest = ({
  trackObjectives,
  track,
  exercise,
  request,
  latestIteration,
  videos,
  links,
  onCreate,
}: {
  trackObjectives: string
  track: Track
  exercise: Exercise
  request?: Request
  latestIteration: Iteration
  videos: Video[]
  links: DiscussionLinks
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
      trackObjectives={trackObjectives}
      track={track}
      exercise={exercise}
      onSuccess={onCreate}
      links={links}
    />
  )
}
