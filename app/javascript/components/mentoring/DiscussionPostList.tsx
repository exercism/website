import React, { useEffect } from 'react'
import { useRequestQuery } from '../../hooks/request-query'
import { DiscussionPost, DiscussionPostProps } from './DiscussionPost'
import { DiscussionPostChannel } from '../../channels/discussionPostChannel'

export const DiscussionPostList = ({
  endpoint,
  discussionId,
  iterationIdx,
}: {
  endpoint: string
  discussionId: number
  iterationIdx: number
}): JSX.Element | null => {
  const { isSuccess, data: posts, refetch } = useRequestQuery<
    DiscussionPostProps[]
  >(endpoint, { endpoint: endpoint, options: {} })

  useEffect(() => {
    const channel = new DiscussionPostChannel(
      { discussionId: discussionId, iterationIdx: iterationIdx },
      refetch
    )

    return () => {
      channel.disconnect()
    }
  }, [discussionId, iterationIdx, refetch])

  if (isSuccess && posts) {
    return (
      <div>
        {posts.map((post) => (
          <DiscussionPost key={post.id} {...post} />
        ))}
      </div>
    )
  }

  return null
}
