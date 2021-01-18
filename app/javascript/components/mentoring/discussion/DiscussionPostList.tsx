import React, {
  useEffect,
  useMemo,
  useRef,
  useContext,
  useState,
  useCallback,
} from 'react'
import { useQuery, queryCache } from 'react-query'
import { DiscussionPost, DiscussionPostProps } from './DiscussionPost'
import { DiscussionPostChannel } from '../../../channels/discussionPostChannel'
import { Loading } from '../../common/Loading'
import { CacheContext, Iteration } from '../Discussion'
import { sendRequest } from '../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { typecheck } from '../../../utils/typecheck'
import { IterationMarker } from './IterationMarker'

type IterationWithPost = {
  idx: number
  createdAt: string
  posts: DiscussionPostProps[]
}

export const DiscussionPostList = ({
  endpoint,
  discussionId,
  userId,
  iterations,
}: {
  endpoint: string
  discussionId: number
  userId: number
  iterations: readonly Iteration[]
}): JSX.Element | null => {
  const isMountedRef = useIsMounted()
  const { posts: cacheKey } = useContext(CacheContext)
  const [hasNewMessages, setHasNewMessages] = useState(false)
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
    if (!data) {
      return []
    }

    return data.reduce<IterationWithPost[]>((iterationsWithPosts, post) => {
      const iterationWithPost = iterationsWithPosts.find(
        (iteration) => iteration.idx === post.iterationIdx
      )

      if (iterationWithPost) {
        iterationWithPost.posts.push(post)
      } else {
        const iteration = iterations.find(
          (iteration) => iteration.idx === post.iterationIdx
        )

        if (!iteration) {
          throw new Error('Iteration idx does not exist')
        }

        iterationsWithPosts.push({
          idx: iteration.idx,
          createdAt: iteration.createdAt,
          posts: [post],
        })
      }

      return iterationsWithPosts
    }, [])
  }, [data, iterations])
  const lastPostRef = useRef<HTMLDivElement>(null)
  const observer = useRef<IntersectionObserver | null>()

  const scrollToLastMessage = useCallback(() => {
    if (!lastPostRef.current) {
      return
    }

    lastPostRef.current.scrollIntoView()
  }, [lastPostRef])

  useEffect(() => {
    if (!data || data.length === 0) {
      return
    }

    const lastPost = data[data.length - 1]

    if (lastPost.authorId === userId) {
      scrollToLastMessage()
    } else {
      setHasNewMessages(true)
    }
  }, [data, scrollToLastMessage, userId])

  useEffect(() => {
    if (!lastPostRef.current) {
      return
    }

    observer.current = new IntersectionObserver((entries) => {
      if (!entries[0].isIntersecting) {
        return
      }

      setHasNewMessages(false)
    })
    observer.current.observe(lastPostRef.current)

    return () => {
      observer.current?.disconnect()
    }
  }, [data])

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
        {hasNewMessages ? (
          <button type="button" onClick={() => scrollToLastMessage()}>
            View new messages
          </button>
        ) : null}
        {iterationsWithPosts.map((iteration) => {
          return (
            <React.Fragment key={iteration.idx}>
              <IterationMarker
                idx={iteration.idx}
                createdAt={iteration.createdAt}
              />
              {iteration.posts.map((post) => {
                if (
                  iterationsWithPosts[iterationsWithPosts.length - 1] ===
                  iteration
                ) {
                  return (
                    <DiscussionPost ref={lastPostRef} key={post.id} {...post} />
                  )
                } else {
                  return <DiscussionPost key={post.id} {...post} />
                }
              })}
            </React.Fragment>
          )
        })}
      </div>
    )
  }

  return null
}
