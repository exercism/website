import React, { useEffect, useMemo, useRef, useContext } from 'react'
import { useQuery, queryCache } from 'react-query'
import { DiscussionPost, DiscussionPostProps } from './DiscussionPost'
import { DiscussionPostChannel } from '../../../channels/discussionPostChannel'
import { Loading } from '../../common/Loading'
import { Iteration, Student } from '../Session'
import { sendRequest } from '../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { typecheck } from '../../../utils/typecheck'
import { IterationMarker } from '../session/IterationMarker'
import { DiscussionContext } from './DiscussionContext'

type IterationWithPost = Iteration & { posts: DiscussionPostProps[] }

export const DiscussionPostList = ({
  endpoint,
  discussionId,
  iterations,
  student,
}: {
  endpoint: string
  discussionId: string
  iterations: readonly Iteration[]
  student: Student
}): JSX.Element | null => {
  const isMountedRef = useIsMounted()
  const {
    cacheKey,
    handlePostsChange,
    highlightedPost,
    handlePostHighlight,
    handleAfterPostHighlight,
    highlightedPostRef,
  } = useContext(DiscussionContext)
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
  const observer = useRef<IntersectionObserver | null>()

  useEffect(() => {
    if (!highlightedPostRef.current) {
      return
    }

    handlePostHighlight(highlightedPostRef.current)
  }, [handlePostHighlight, highlightedPost, highlightedPostRef])

  useEffect(() => {
    if (!data || data.length === 0) {
      return
    }

    handlePostsChange(data)
  }, [data, handlePostsChange])

  useEffect(() => {
    if (!highlightedPostRef.current) {
      return
    }

    observer.current = new IntersectionObserver((entries) => {
      if (!entries[0].isIntersecting) {
        return
      }

      handleAfterPostHighlight()
    })
    observer.current.observe(highlightedPostRef.current)

    return () => {
      observer.current?.disconnect()
    }
  }, [data, highlightedPost, handleAfterPostHighlight, highlightedPostRef])

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
