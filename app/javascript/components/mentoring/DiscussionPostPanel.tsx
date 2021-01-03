import React from 'react'
import { DiscussionPostList } from './DiscussionPostList'
import { AddDiscussionPost } from './AddDiscussionPost'

export const DiscussionPostPanel = ({
  endpoint,
  discussionId,
  iterationIdx,
}: {
  endpoint: string
  discussionId: number
  iterationIdx: number
}): JSX.Element => {
  return (
    <div>
      <DiscussionPostList
        endpoint={endpoint}
        discussionId={discussionId}
        iterationIdx={iterationIdx}
      />
      <AddDiscussionPost
        endpoint={endpoint}
        contextId={`${discussionId}_${iterationIdx}_new_post`}
      />
    </div>
  )
}
