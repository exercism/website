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
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Icon } from '../../common/Icon'
import { Avatar } from '../../common/Avatar'
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
          <button
            className="new-messages-button"
            type="button"
            onClick={() => scrollToLastMessage()}
          >
            TODO: This should be moved into the place it is in
            AddDiscussionPost.tsx
          </button>
        ) : null}
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
                    WDNewmann recieved automated feedback
                  </div>
                  <GraphicalIcon
                    icon="chevron-right"
                    className="--closed-icon"
                  />
                  <GraphicalIcon icon="chevron-down" className="--open-icon" />
                </summary>
                <div className="feedback">
                  <div className="c-textual-content --small">
                    <p>
                      The biggest improvement you could make to this would be to
                      use Ruby's String helper methods rather than regular
                      expressions. That will help make it much more readable to
                      future-you or another developer. Take a look at the String
                      docs and check out things such as <code>strip</code> and{' '}
                      <code>end_with?</code>.
                    </p>
                  </div>
                  <div className="byline">
                    <Avatar
                      src="https://avatars2.githubusercontent.com/u/5337876?s=460&v=4"
                      handle="mentor handle"
                    />
                    <div className="name">by ErikSchierboom</div>
                    {/* TODO: Extract to common reputation component */}
                    <div className="c-reputation" aria-label="20 reputation">
                      <GraphicalIcon icon="reputation" />
                      <span>20</span>
                    </div>
                  </div>
                  <a href="#" className="more">
                    Learn more about this feedback
                    <Icon icon="external-link" alt="Opens in new tab" />
                  </a>
                </div>
              </details>
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
