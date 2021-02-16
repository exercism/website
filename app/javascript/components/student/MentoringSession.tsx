import React from 'react'
import { DiscussionPostList } from '../mentoring/discussion/DiscussionPostList'
import { AddDiscussionPost } from '../mentoring/discussion/AddDiscussionPost'
import { NewMessageAlert } from '../mentoring/discussion/NewMessageAlert'
import { Iteration, Partner, Track } from '../mentoring/Session'
import { IterationView } from '../mentoring/session/IterationView'
import { PostsWrapper } from '../mentoring/discussion/PostsContext'

type Links = {
  posts: string
}

export const MentoringSession = ({
  id,
  isFinished,
  links,
  iterations,
  student,
  track,
  userId,
}: {
  id: string
  isFinished: boolean
  links: Links
  iterations: readonly Iteration[]
  student: Partner
  track: Track
  userId: number
}): JSX.Element => {
  return (
    <div className="c-mentor-discussion">
      <div className="lhs">
        <header className="discussion-header"></header>
        <IterationView
          iterations={iterations}
          language={track.highlightjsLanguage}
        />
      </div>
      <div className="rhs">
        <PostsWrapper discussionId={id}>
          <div id="panel-discussion">
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
