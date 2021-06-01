import React from 'react'
import { DiscussionPostList } from '../../mentoring/discussion/DiscussionPostList'
import { AddDiscussionPost } from '../../mentoring/discussion/AddDiscussionPost'
import { NewMessageAlert } from '../../mentoring/discussion/NewMessageAlert'
import { PostsWrapper } from '../../mentoring/discussion/PostsContext'
import { MentorInfo } from './MentorInfo'
import { MentorDiscussion, Iteration } from '../../types'
import { Mentor } from '../MentoringSession'

export const DiscussionInfo = ({
  discussion,
  mentor,
  userId,
  iterations,
  onIterationScroll,
}: {
  discussion: MentorDiscussion
  mentor: Mentor
  userId: number
  iterations: readonly Iteration[]
  onIterationScroll: (iteration: Iteration) => void
}): JSX.Element => {
  return (
    <PostsWrapper discussionId={discussion.id}>
      <div id="panel-discussion">
        <MentorInfo mentor={mentor} />
        <div className="discussion">
          <DiscussionPostList
            endpoint={discussion.links.posts}
            iterations={iterations}
            userIsStudent={true}
            discussionId={discussion.id}
            userId={userId}
            onIterationScroll={onIterationScroll}
          />
        </div>
      </div>
      <section className="comment-section --comment">
        <NewMessageAlert />
        <AddDiscussionPost
          isFinished={discussion.isFinished}
          endpoint={discussion.links.posts}
          contextId={`discussion-${discussion.id}_new_post`}
        />
      </section>
    </PostsWrapper>
  )
}
