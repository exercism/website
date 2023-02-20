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
  DiscussionLinks,
} from '../types'
import { MentoringRequest } from './mentoring-session/MentoringRequest'
import { SplitPane } from '../common'

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
  reputation: number
  numDiscussions: number
}

export const MentoringSession = ({
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
  links: DiscussionLinks
  outOfDate: boolean
}): JSX.Element => {
  const [mentorRequest, setMentorRequest] = useState(initialRequest)

  const handleCreateMentorRequest = useCallback((mentorRequest) => {
    setMentorRequest(mentorRequest)
  }, [])

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
                <DiscussionActions discussion={discussion} links={links} />
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
                links={links}
                status={status}
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
