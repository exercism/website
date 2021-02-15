import React from 'react'
import { DiscussionPostList } from '../mentoring/discussion/DiscussionPostList'
import { AddDiscussionPost } from '../mentoring/discussion/AddDiscussionPost'
import { NewMessageAlert } from '../mentoring/discussion/NewMessageAlert'
import { Iteration, Student } from '../mentoring/Session'
import { PostsWrapper } from '../mentoring/discussion/DiscussionContext'

type Links = {
  posts: string
}

export const MentoringSession = ({
  id,
  isFinished,
  links,
  iterations,
  student,
  userId,
}: {
  id: string
  isFinished: boolean
  links: Links
  iterations: readonly Iteration[]
  student: Student
  userId: number
}): JSX.Element => {
  return (
    <div className="c-mentor-discussion">
      <div className="lhs" />
      <div className="rhs">
        <PostsWrapper cacheKey={`posts-discussion-${id}`}>
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
