import React from 'react'
import { useRequestQuery } from '../../hooks/request-query'
import { DiscussionPost, DiscussionPostProps } from './DiscussionPost'

export const DiscussionPostList = ({
  endpoint,
}: {
  endpoint: string
}): JSX.Element | null => {
  const { isSuccess, data: posts } = useRequestQuery<DiscussionPostProps[]>(
    endpoint,
    { endpoint: endpoint, options: {} }
  )

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
