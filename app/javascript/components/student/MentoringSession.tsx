import React, { useCallback, useState } from 'react'

import { CloseButton } from '../mentoring/session/CloseButton'
import { IterationView } from './mentoring-session/IterationView'
import { useIterationScrolling } from '../mentoring/session/useIterationScrolling'
import { SessionInfo } from './mentoring-session/SessionInfo'
import { DiscussionInfo } from './mentoring-session/DiscussionInfo'
import { DiscussionActions } from './mentoring-session/DiscussionActions'

import { useDiscussionIterations } from '../mentoring/discussion/use-discussion-iterations'

import {
  Iteration,
  MentorDiscussion,
  MentorSessionRequest as Request,
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
  MentoringSessionDonation,
  MentoringSessionLinks,
} from '../types'
import { MentoringRequest } from './mentoring-session/MentoringRequest'
import { SplitPane } from '../common/SplitPane'
import { Flair } from '../common/HandleWithFlair'

export type Links = {
  exercise: string
  learnMoreAboutPrivateMentoring: string
  privateMentoring: string
  mentoringGuide: string
  createMentorRequest: string
  donationsSettings: string
  donate: string
}

export type Video = {
  url: string
  thumb: string
  title: string
  date: string
}

export type Mentor = {
  id: number
  avatarUrl: string
  name: string
  bio: string
  handle: string
  flair: Flair
  reputation: number
  numDiscussions: number
  pronouns?: string[]
}

export default function MentoringSession({
  userHandle,
  discussion,
  mentor,
  iterations: initialIterations,
  exercise,
  trackObjectives,
  videos,
  track,
  request: initialRequest,
  links,
  outOfDate,
  donation,
}: {
  userHandle: string
  discussion?: MentorDiscussion
  mentor?: Mentor
  iterations: readonly Iteration[]
  exercise: Exercise
  trackObjectives: string
  videos: Video[]
  track: Track
  request?: Request
  links: MentoringSessionLinks
  outOfDate: boolean
  donation: MentoringSessionDonation
}): JSX.Element {
  const [mentorRequest, setMentorRequest] = useState(initialRequest)

  const handleCreateMentorRequest = useCallback(
    (mentorRequest: typeof initialRequest) => {
      setMentorRequest(mentorRequest)
    },
    []
  )

  const { iterations, status } = useDiscussionIterations({
    discussion: discussion,
    iterations: initialIterations,
  })

  const [isLinked, setIsLinked] = useState(false)
  const { currentIteration, handleIterationClick, handleIterationScroll } =
    useIterationScrolling({
      iterations: iterations,
      on: isLinked,
    })

  return (
    <div className="c-mentor-discussion">
      <SplitPane
        id="mentoring-session"
        defaultLeftWidth="90%"
        leftMinWidth={550}
        rightMinWidth={625}
        left={
          <>
            <header className="discussion-header">
              <CloseButton url={links.exercise} />
              <SessionInfo track={track} exercise={exercise} mentor={mentor} />
              {discussion ? (
                <DiscussionActions
                  discussion={discussion}
                  links={{
                    ...links,
                    exercise: exercise.links.self,
                    exerciseMentorDiscussionUrl: links.exercise,
                  }}
                  donation={donation}
                />
              ) : null}
            </header>
            <IterationView
              iterations={iterations}
              currentIteration={currentIteration}
              onClick={handleIterationClick}
              language={track.highlightjsLanguage}
              indentSize={track.indentSize}
              isOutOfDate={outOfDate}
              isLinked={isLinked}
              setIsLinked={setIsLinked}
              discussion={discussion}
            />
          </>
        }
        right={
          <>
            {discussion && mentor ? (
              <DiscussionInfo
                discussion={discussion}
                mentor={mentor}
                userHandle={userHandle}
                iterations={iterations}
                onIterationScroll={handleIterationScroll}
                links={{
                  ...links,
                  exercise: exercise.links.self,
                  exerciseMentorDiscussionUrl: links.exercise,
                }}
                status={status}
                donation={donation}
              />
            ) : (
              <MentoringRequest
                trackObjectives={trackObjectives}
                track={track}
                exercise={exercise}
                request={mentorRequest}
                latestIteration={iterations[iterations.length - 1]}
                videos={videos}
                links={links}
                onCreate={handleCreateMentorRequest}
              />
            )}
          </>
        }
      />
    </div>
  )
}
