import React from 'react'
import { DiscussionPostList } from './DiscussionPostList'

export const DiscussionPostPanel = ({
  endpoint,
  discussionId,
  iterationIdx,
}: {
  endpoint: string
  discussionId: number
  iterationIdx: number
}): JSX.Element | null => (
  <DiscussionPostList
    endpoint={endpoint}
    discussionId={discussionId}
    iterationIdx={iterationIdx}
  />
)
