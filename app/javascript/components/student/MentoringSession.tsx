import React, { useCallback, useState } from 'react'

import { CloseButton } from '../mentoring/session/CloseButton'
import { IterationView } from '../mentoring/session/IterationView'
import { SessionInfo } from './mentoring-session/SessionInfo'
import { DiscussionInfo } from './mentoring-session/DiscussionInfo'

import {
  Iteration,
  MentorDiscussion,
  MentoringRequest as MentoringRequestProps,
} from '../types'
import { MentoringRequest } from './mentoring-session/MentoringRequest'

export type Links = {
  exercise: string
  learnMoreAboutPrivateMentoring: string
  privateMentoring: string
  mentoringGuide: string
  createMentorRequest: string
}

export type Track = {
  title: string
  highlightjsLanguage: string
  medianWaitTime: string
  iconUrl: string
}

export type Exercise = {
  title: string
  iconName: string
}

export type Video = {
  url: string
  title: string
  date: string
}

export const MentoringSession = ({
  userId,
  discussion,
  iterations,
  exercise,
  isFirstTimeOnTrack,
  videos,
  track,
  request: initialRequest,
  links,
}: {
  userId: number
  discussion?: MentorDiscussion
  iterations: readonly Iteration[]
  exercise: Exercise
  isFirstTimeOnTrack: boolean
  videos: Video[]
  track: Track
  request?: MentoringRequestProps
  links: Links
}): JSX.Element => {
  const [mentorRequest, setMentorRequest] = useState(initialRequest)

  const handleCreateMentorRequest = useCallback((mentorRequest) => {
    setMentorRequest(mentorRequest)
  }, [])

  return (
    <div className="c-mentor-discussion">
      <div className="lhs">
        <header className="discussion-header">
          <CloseButton url={links.exercise} />
          <SessionInfo
            track={track}
            exercise={exercise}
            mentor={discussion?.mentor}
          />
        </header>
        <IterationView
          iterations={iterations}
          language={track.highlightjsLanguage}
        />
      </div>
      <div className="rhs">
        {discussion ? (
          <DiscussionInfo
            discussion={discussion}
            userId={userId}
            iterations={iterations}
          />
        ) : (
          <MentoringRequest
            isFirstTimeOnTrack={isFirstTimeOnTrack}
            track={track}
            exercise={exercise}
            request={mentorRequest}
            latestIteration={iterations[iterations.length - 1]}
            videos={videos}
            links={links}
            onCreate={handleCreateMentorRequest}
          />
        )}
      </div>
    </div>
  )
}
