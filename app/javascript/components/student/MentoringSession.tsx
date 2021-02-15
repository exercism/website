import React from 'react'
import { DiscussionPostList } from '../mentoring/discussion/DiscussionPostList'
import { AddDiscussionPost } from '../mentoring/discussion/AddDiscussionPost'
import { Iteration, Student } from '../mentoring/Session'

type Links = {
  posts: string
}

export const MentoringSession = ({
  id,
  isFinished,
  links,
  iterations,
  student,
}: {
  id: string
  isFinished: boolean
  links: Links
  iterations: readonly Iteration[]
  student: Student
}): JSX.Element => {
  return (
    <div className="c-mentor-discussion">
      <div className="lhs" />
      <div className="rhs">
        <div id="panel-discussion">
          <DiscussionPostList
            endpoint={links.posts}
            iterations={iterations}
            student={student}
            discussionId={id}
          />
        </div>
        <section className="comment-section">
          <AddDiscussionPost
            isFinished={isFinished}
            endpoint={links.posts}
            contextId={`discussion-${id}_new_post`}
          />
        </section>
      </div>
    </div>
  )
}
