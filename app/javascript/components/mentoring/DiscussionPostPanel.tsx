import React from 'react'
import { DiscussionPostList } from './DiscussionPostList'
import { AddDiscussionPost } from './AddDiscussionPost'
import { Iteration } from './MentorDiscussion'

export const DiscussionPostPanel = ({
  discussionId,
  iteration,
}: {
  discussionId: number
  iteration: Iteration
}): JSX.Element => {
  return (
    <div>
      <DiscussionPostList
        endpoint={iteration.links.posts}
        discussionId={discussionId}
        iterationIdx={iteration.idx}
      />
      <AddDiscussionPost
        endpoint={iteration.links.posts}
        contextId={`${discussionId}_${iteration.idx}_new_post`}
      />
    </div>
  )
}
