import React, { useEffect, useMemo, useContext } from 'react'
import { usePostHighlighting } from './usePostHighlighting'
import { useQuery, queryCache } from 'react-query'
import { DiscussionPost, DiscussionPostProps } from './DiscussionPost'
import { DiscussionPostChannel } from '../../../channels/discussionPostChannel'
import { Loading } from '../../common/Loading'
import { Iteration, Student } from '../Session'
import { sendRequest } from '../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { typecheck } from '../../../utils/typecheck'
import { IterationMarker } from '../session/IterationMarker'
import { PostsContext } from './PostsContext'

type IterationWithPost = Iteration & { posts: DiscussionPostProps[] }

export const DiscussionPostList = ({
  endpoint,
  discussionId,
  iterations,
  student,
  userId,
}: {
  endpoint: string
  discussionId: string
  iterations: readonly Iteration[]
  student: Student
  userId: number
}): JSX.Element | null => {
  const isMountedRef = useIsMounted()
  const { cacheKey } = useContext(PostsContext)
  const { status, data } = useQuery<DiscussionPostProps[]>(cacheKey, () => {
    return sendRequest({
      endpoint: endpoint,
      method: 'GET',
      body: null,
      isMountedRef: isMountedRef,
    }).then((json) => {
      return typecheck<DiscussionPostProps[]>(json, 'posts')
    })
  })
  const iterationsWithPosts = useMemo(() => {
    return iterations.reduce<IterationWithPost[]>(
      (iterationsWithPosts, iteration) => {
        const posts = data
          ? data.filter((post) => post.iterationIdx === iteration.idx)
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

  const { highlightedPost, highlightedPostRef } = usePostHighlighting(
    data,
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
        {iterationsWithPosts.map((iteration) => {
          return (
            <React.Fragment key={iteration.idx}>
              <IterationMarker iteration={iteration} student={student} />
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
