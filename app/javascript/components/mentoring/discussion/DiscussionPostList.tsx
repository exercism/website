import React, {
  useEffect,
  useMemo,
  useContext,
  useState,
  useCallback,
  createRef,
} from 'react'
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

type IterationWithPost = {
  iteration: Iteration
  posts: DiscussionPostProps[]
  ref: React.RefObject<HTMLDivElement>
}

type IntersectionStatus = {
  iteration: Iteration
  isIntersecting: boolean
}

export const DiscussionPostList = ({
  endpoint,
  discussionId,
  iterations,
  userId,
  userIsStudent,
  onIterationScroll,
}: {
  endpoint: string
  discussionId: string
  iterations: readonly Iteration[]
  userId: number
  userIsStudent: boolean
  onIterationScroll: (iteration: Iteration) => void
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
  const [iterationsWithPosts, setIterationWithPosts] = useState<
    IterationWithPost[]
  >([])
  const startIteration = iterationsWithPosts.findIndex(
    (iteration) => iteration.posts.length !== 0
  )
  const iterationsToShow = useMemo(
    () => iterationsWithPosts.slice(startIteration),
    [iterationsWithPosts, startIteration]
  )
  const { highlightedPost, highlightedPostRef } = usePostHighlighting(
    posts,
    userId
  )
  const [intersectionStatus, setIntersectionStatus] = useState<
    IntersectionStatus[]
  >([])

  const registerEntry = useCallback(
    (entries: IntersectionObserverEntry[]) => {
      setIntersectionStatus(
        iterationsWithPosts.map((i) => {
          const matchingEntry = entries.find((e) => e.target === i.ref.current)

          return {
            iteration: i.iteration,
            isIntersecting: matchingEntry
              ? matchingEntry.isIntersecting
              : false,
          }
        })
      )
    },
    [iterationsWithPosts]
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
    setIterationWithPosts(
      iterations.reduce<IterationWithPost[]>(
        (iterationsWithPosts, iteration) => {
          const iterationPosts = posts
            ? posts.filter((post) => post.iterationIdx === iteration.idx)
            : []

          iterationsWithPosts.push({
            iteration: iteration,
            posts: iterationPosts,
            ref: createRef<HTMLDivElement>(),
          })

          return iterationsWithPosts
        },
        []
      )
    )
  }, [iterations, posts])

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

  useEffect(() => {
    const observer = new IntersectionObserver(registerEntry, {
      threshold: 1,
      root: null,
      rootMargin: '0px',
    })

    iterationsToShow.forEach((i) => {
      if (!i.ref.current) {
        return
      }

      observer.observe(i.ref.current)
    })

    return () => {
      observer.disconnect()
    }
  }, [iterationsToShow, registerEntry])

  useEffect(() => {
    const intersectingIteration = intersectionStatus.filter(
      (s) => s.isIntersecting
    )[0]

    if (!intersectingIteration) {
      return
    }

    onIterationScroll(intersectingIteration.iteration)
  }, [intersectionStatus, onIterationScroll])

  if (status === 'loading') {
    return (
      <div role="status" aria-label="Discussion post list loading indicator">
        <Loading />
      </div>
    )
  }

  if (posts) {
    return (
      <>
        {iterationsToShow.map((iteration) => {
          return (
            <React.Fragment key={iteration.iteration.idx}>
              <IterationMarker
                iteration={iteration.iteration}
                userIsStudent={userIsStudent}
                ref={iteration.ref}
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
      </>
    )
  }
  return null
}
