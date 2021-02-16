import React from 'react'

import { CloseButton } from '../mentoring/session/CloseButton'
import { DiscussionPostList } from '../mentoring/discussion/DiscussionPostList'
import { AddDiscussionPost } from '../mentoring/discussion/AddDiscussionPost'
import { NewMessageAlert } from '../mentoring/discussion/NewMessageAlert'
import { Iteration, Track, Exercise } from '../mentoring/Session'
import { IterationView } from '../mentoring/session/IterationView'
import { PostsWrapper } from '../mentoring/discussion/PostsContext'
import { MentorInfo } from './mentoring-session/MentorInfo'
import { SessionInfo } from './mentoring-session/SessionInfo'

type Links = {
  posts: string
  exercise: string
}

export type Mentor = {
  id: number
  avatarUrl: string
  name: string
  bio: string
  handle: string
  reputation: number
  numPreviousSessions: number
}

export const MentoringSession = ({
  id,
  isFinished,
  links,
  iterations,
  mentor,
  track,
  exercise,
  userId,
}: {
  id: string
  isFinished: boolean
  links: Links
  iterations: readonly Iteration[]
  mentor: Mentor
  track: Track
  exercise: Exercise
  userId: number
}): JSX.Element => {
  return (
    <div className="c-mentor-discussion">
      <div className="lhs">
        <header className="discussion-header">
          <CloseButton url={links.exercise} />
          <SessionInfo track={track} exercise={exercise} mentor={mentor} />
        </header>
        <IterationView
          iterations={iterations}
          language={track.highlightjsLanguage}
        />
      </div>
      <div className="rhs">
        <PostsWrapper discussionId={id}>
          <div id="panel-discussion">
            <MentorInfo mentor={mentor} />
            <DiscussionPostList
              endpoint={links.posts}
              iterations={iterations}
              userIsStudent={true}
              discussionId={id}
              userId={userId}
            />
          </div>
          <section className="comment-section">
            <NewMessageAlert />
            <AddDiscussionPost
              isFinished={isFinished}
              endpoint={links.posts}
              contextId={`discussion-${id}_new_post`}
            />
          </section>
        </PostsWrapper>
      </div>
    </div>
  )
}
