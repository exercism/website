import React from 'react'
import { DiscussionPostList } from './DiscussionPostList'
import { DiscussionPostForm } from './DiscussionPostForm'

export const DiscussionPostPanel = ({
  endpoint,
  discussionId,
  iterationIdx,
}: {
  endpoint: string
  discussionId: number
  iterationIdx: number
}): JSX.Element | null => {
  return (
    <div>
      <DiscussionPostList
        endpoint={endpoint}
        discussionId={discussionId}
        iterationIdx={iterationIdx}
      />
      <DiscussionPostForm
        endpoint={endpoint}
        contextId={`${discussionId}_${iterationIdx}_new_post`}
      />
    </div>
  )
}
