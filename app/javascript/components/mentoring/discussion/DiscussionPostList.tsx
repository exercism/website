import React, { useEffect, useMemo, useRef, useContext } from 'react'
import { useQuery, queryCache } from 'react-query'
import { DiscussionPost, DiscussionPostProps } from './DiscussionPost'
import { DiscussionPostChannel } from '../../../channels/discussionPostChannel'
import { Loading } from '../../common/Loading'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import {
  CacheContext,
  Iteration,
  AutomatedFeedback,
  Student,
} from '../Discussion'
import { sendRequest } from '../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { typecheck } from '../../../utils/typecheck'
import { IterationMarker } from './IterationMarker'
import { RepresenterFeedback } from './RepresenterFeedback'

type IterationWithPost = {
  idx: number
  createdAt: string
  posts: DiscussionPostProps[]
  automatedFeedback: AutomatedFeedback
}

export const DiscussionPostList = ({
  endpoint,
  discussionId,
  iterations,
  highlightedPost,
  onPostsChange,
  onPostHighlight,
  onAfterPostHighlight,
  student,
}: {
  endpoint: string
  discussionId: number
  iterations: readonly Iteration[]
  highlightedPost: DiscussionPostProps | null
  onPostsChange: (posts: DiscussionPostProps[]) => void
  onPostHighlight: (element: HTMLDivElement) => void
  onAfterPostHighlight: () => void
  student: Student
}): JSX.Element | null => {
  const isMountedRef = useIsMounted()
  const { posts: cacheKey } = useContext(CacheContext)
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
          idx: iteration.idx,
          automatedFeedback: iteration.automatedFeedback,
          createdAt: iteration.createdAt,
          posts: posts,
        })

        return iterationsWithPosts
      },
      []
    )
  }, [data, iterations])
  const highlightedPostRef = useRef<HTMLDivElement>(null)
  const observer = useRef<IntersectionObserver | null>()

  useEffect(() => {
    if (!highlightedPostRef.current) {
      return
    }

    onPostHighlight(highlightedPostRef.current)
  }, [highlightedPost, onPostHighlight])

  useEffect(() => {
    if (!data || data.length === 0) {
      return
    }

    onPostsChange(data)
  }, [data, onPostsChange])

  useEffect(() => {
    if (!highlightedPostRef.current) {
      return
    }

    observer.current = new IntersectionObserver((entries) => {
      if (!entries[0].isIntersecting) {
        return
      }

      onAfterPostHighlight()
    })
    observer.current.observe(highlightedPostRef.current)

    return () => {
      observer.current?.disconnect()
    }
  }, [data, highlightedPost, onAfterPostHighlight])

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
              <IterationMarker
                idx={iteration.idx}
                createdAt={iteration.createdAt}
              />
              <details className="c-details auto-feedback">
                <summary>
                  <GraphicalIcon icon="alert-circle" className="info-icon" />
                  <div className="info">
                    {student.handle} received automated feedback
                  </div>
                  <GraphicalIcon
                    icon="chevron-right"
                    className="--closed-icon"
                  />
                  <GraphicalIcon icon="chevron-down" className="--open-icon" />
                </summary>
                <RepresenterFeedback {...iteration.automatedFeedback.mentor} />
              </details>
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
