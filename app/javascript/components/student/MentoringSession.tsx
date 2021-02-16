import React from 'react'
import { DiscussionPostList } from '../mentoring/discussion/DiscussionPostList'
import { AddDiscussionPost } from '../mentoring/discussion/AddDiscussionPost'
import { NewMessageAlert } from '../mentoring/discussion/NewMessageAlert'
import { Iteration, Partner, Track, Exercise } from '../mentoring/Session'
import { IterationView } from '../mentoring/session/IterationView'
import { PostsWrapper } from '../mentoring/discussion/PostsContext'
import { PartnerInfo } from '../mentoring/session/PartnerInfo'
import { SessionInfo } from './mentoring-session/SessionInfo'

type Links = {
  posts: string
}

export const MentoringSession = ({
  id,
  isFinished,
  links,
  iterations,
  student,
  partner,
  track,
  exercise,
  userId,
}: {
  id: string
  isFinished: boolean
  links: Links
  iterations: readonly Iteration[]
  student: Partner
  partner: Partner
  track: Track
  exercise: Exercise
  userId: number
}): JSX.Element => {
  return (
    <div className="c-mentor-discussion">
      <div className="lhs">
        <header className="discussion-header">
          <SessionInfo track={track} exercise={exercise} mentor={partner} />
        </header>
        <IterationView
          iterations={iterations}
          language={track.highlightjsLanguage}
        />
      </div>
      <div className="rhs">
        <PostsWrapper discussionId={id}>
          <div id="panel-discussion">
            <PartnerInfo partner={partner} />
            <DiscussionPostList
              endpoint={links.posts}
              iterations={iterations}
              student={student}
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
