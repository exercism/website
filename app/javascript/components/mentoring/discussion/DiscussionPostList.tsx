import React, { useEffect, useMemo, useContext } from 'react'
import { usePostHighlighting } from './usePostHighlighting'
import { queryCache } from 'react-query'
import { DiscussionPost, DiscussionPostProps } from './DiscussionPost'
import { DiscussionPostChannel } from '../../../channels/discussionPostChannel'
import { Loading } from '../../common/Loading'
import { Iteration } from '../../types'
import { useIsMounted } from 'use-is-mounted'
import { IterationMarker } from '../session/IterationMarker'
import { PostsContext } from './PostsContext'
import { useRequestQuery } from '../../../hooks/request-query'

type IterationWithPost = Iteration & { posts: DiscussionPostProps[] }

export const DiscussionPostList = ({
  endpoint,
  discussionId,
  iterations,
  userId,
  userIsStudent,
}: {
  endpoint: string
  discussionId: string
  iterations: readonly Iteration[]
  userId: number
  userIsStudent: boolean
}): JSX.Element | null => {
  const isMountedRef = useIsMounted()
  const { cacheKey } = useContext(PostsContext)
  const { status, data } = useRequestQuery<{ posts: DiscussionPostProps[] }>(
    cacheKey,
    { endpoint: endpoint, options: {} },
    isMountedRef
  )
  const iterationsWithPosts = useMemo(() => {
    return iterations.reduce<IterationWithPost[]>(
      (iterationsWithPosts, iteration) => {
        const posts = data?.posts
          ? data.posts.filter((post) => post.iterationIdx === iteration.idx)
          : []

        iterationsWithPosts.push({
          ...iteration,
          posts: posts,
        })

        return iterationsWithPosts
      },
      []
    )
  }, [data, iterations])
  const startIteration = iterationsWithPosts.findIndex(
    (iteration) => iteration.posts.length !== 0
  )
  const { highlightedPost, highlightedPostRef } = usePostHighlighting(
    data?.posts,
    userId
  )

  useEffect(() => {
    const channel = new DiscussionPostChannel(
      { discussionId: discussionId },
      () => {
        queryCache.invalidateQueries(cacheKey)
      }
    )

    return () => {
      channel.disconnect()
    }
  }, [cacheKey, discussionId])

  if (status === 'loading') {
    return (
      <div role="status" aria-label="Discussion post list loading indicator">
        <Loading />
      </div>
    )
  }

  if (data) {
    return (
      <div className="discussion">
        {iterationsWithPosts.slice(startIteration).map((iteration) => {
          return (
            <React.Fragment key={iteration.idx}>
              <IterationMarker
                iteration={iteration}
                userIsStudent={userIsStudent}
              />
              {iteration.posts.map((post) => {
                return (
                  <DiscussionPost
                    ref={highlightedPost === post ? highlightedPostRef : null}
                    key={post.id}
                    {...post}
                  />
                )
              })}
            </React.Fragment>
          )
        })}
      </div>
    )
  }
  return null
}
