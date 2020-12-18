import React, { useEffect } from 'react'
import { useRequestQuery } from '../../hooks/request-query'
import { DiscussionPost, DiscussionPostProps } from './DiscussionPost'
import { DiscussionPostChannel } from '../../channels/discussionPostChannel'

export const DiscussionPostList = ({
  endpoint,
  discussionId,
  iterationId,
}: {
  endpoint: string
  discussionId: number
  iterationId: number
}): JSX.Element | null => {
  const { isSuccess, data: posts, refetch } = useRequestQuery<
    DiscussionPostProps[]
  >(endpoint, { endpoint: endpoint, options: {} })

  useEffect(() => {
    const channel = new DiscussionPostChannel(
      { discussionId: discussionId, iterationId: iterationId },
      refetch
    )

    return () => {
      channel.disconnect()
    }
  }, [discussionId, iterationId, refetch])

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
