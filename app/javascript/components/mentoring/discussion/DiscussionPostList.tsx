import React, { useEffect, useMemo } from 'react'
import { useRequestQuery } from '../../../hooks/request-query'
import { DiscussionPost, DiscussionPostProps } from './DiscussionPost'
import { DiscussionPostChannel } from '../../../channels/discussionPostChannel'
import { Loading } from '../../common/Loading'

type Iteration = {
  idx: number
  posts: DiscussionPostProps[]
}

export const DiscussionPostList = ({
  endpoint,
  discussionId,
}: {
  endpoint: string
  discussionId: number
}): JSX.Element | null => {
  const { isSuccess, isLoading, data, refetch } = useRequestQuery<{
    posts: DiscussionPostProps[]
  }>(endpoint, { endpoint: endpoint, options: {} })

  const iterations = useMemo(() => {
    if (!data) {
      return []
    }

    return data.posts.reduce<Iteration[]>((iterations, post) => {
      const iteration = iterations.find(
        (iteration) => iteration.idx === post.iterationIdx
      )

      if (iteration) {
        iteration.posts.push(post)
      } else {
        iterations.push({ idx: post.iterationIdx, posts: [post] })
      }

      return iterations
    }, [])
  }, [data])

  useEffect(() => {
    const channel = new DiscussionPostChannel(
      { discussionId: discussionId },
      refetch
    )

    return () => {
      channel.disconnect()
    }
  }, [discussionId, refetch])

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
        {iterations.map((iteration) => {
          return (
            <div key={iteration.idx}>
              <div>Iteration {iteration.idx}</div>
              {iteration.posts.map((post) => {
                return <DiscussionPost key={post.id} {...post} />
              })}
            </div>
          )
        })}
      </div>
    )
  }

  return null
}
