import React, { useEffect } from 'react'
import { useRequestQuery } from '../../../hooks/request-query'
import { DiscussionPost, DiscussionPostProps } from './DiscussionPost'
import { DiscussionPostChannel } from '../../../channels/discussionPostChannel'
import { Loading } from '../../common/Loading'

export const DiscussionPostList = ({
  endpoint,
  discussionId,
  iterationIdx,
}: {
  endpoint: string
  discussionId: number
  iterationIdx: number
}): JSX.Element | null => {
  const { isSuccess, isLoading, data, refetch } = useRequestQuery<{
    posts: DiscussionPostProps[]
  }>(endpoint, { endpoint: endpoint, options: {} })

  useEffect(() => {
    const channel = new DiscussionPostChannel(
      { discussionId: discussionId, iterationIdx: iterationIdx },
      refetch
    )

    return () => {
      channel.disconnect()
    }
  }, [discussionId, iterationIdx, refetch])

  if (isLoading) {
    return (
      <div role="status" aria-label="Discussion post list loading indicator">
        <Loading />
      </div>
    )
  }

  if (isSuccess && data) {
    return (
      <div className="discussion">
        {data.posts.map((post) => (
          <DiscussionPost key={post.id} {...post} />
        ))}
      </div>
    )
  }

  return null
}
