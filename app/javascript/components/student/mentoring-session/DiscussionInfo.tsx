import React from 'react'
import { DiscussionPostList } from '../../mentoring/discussion/DiscussionPostList'
import { AddDiscussionPost } from '../../mentoring/discussion/AddDiscussionPost'
import { NewMessageAlert } from '../../mentoring/discussion/NewMessageAlert'
import { PostsWrapper } from '../../mentoring/discussion/PostsContext'
import { MentorInfo } from './MentorInfo'
import { MentorDiscussion, Iteration } from '../../types'

export const DiscussionInfo = ({
  discussion,
  userId,
  iterations,
}: {
  discussion: MentorDiscussion
  userId: number
  iterations: readonly Iteration[]
}): JSX.Element => {
  return (
    <PostsWrapper discussionId={discussion.id}>
      <div id="panel-discussion">
        <MentorInfo mentor={discussion.mentor} />
        <DiscussionPostList
          endpoint={discussion.links.posts}
          iterations={iterations}
          userIsStudent={true}
          discussionId={discussion.id}
          userId={userId}
        />
      </div>
      <section className="comment-section">
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
