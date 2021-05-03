import React, { useEffect, useMemo, useContext, useState } from 'react'
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
  const { cacheKey, setHasNewMessages } = useContext(PostsContext)
  const { status, data } = useRequestQuery<{ posts: DiscussionPostProps[] }>(
    cacheKey,
    { endpoint: endpoint, options: {} },
    isMountedRef
  )
  const [posts, setPosts] = useState<DiscussionPostProps[] | undefined>(
    undefined
  )
  const iterationsWithPosts = useMemo(() => {
    return iterations.reduce<IterationWithPost[]>(
      (iterationsWithPosts, iteration) => {
        const iterationPosts = posts
          ? posts.filter((post) => post.iterationIdx === iteration.idx)
          : []

        iterationsWithPosts.push({ ...iteration, posts: iterationPosts })

        return iterationsWithPosts
      },
      []
    )
  }, [posts, iterations])
  const startIteration = iterationsWithPosts.findIndex(
    (iteration) => iteration.posts.length !== 0
  )
  const { highlightedPost, highlightedPostRef } = usePostHighlighting(
    posts,
    userId
  )

  useEffect(() => {
    if (!data) {
      return
    }

    setPosts(data.posts)

    if (posts && posts !== data.posts) {
      const lastPost = posts[posts.length - 1]

      if (lastPost.authorId !== userId) {
        setHasNewMessages(true)
      }
    }
  }, [data, posts, setHasNewMessages, userId])

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

  if (posts) {
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
