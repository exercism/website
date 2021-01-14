import React, { useEffect, useMemo, useRef, useContext } from 'react'
import { useRequestQuery } from '../../../hooks/request-query'
import { queryCache } from 'react-query'
import { DiscussionPost, DiscussionPostProps } from './DiscussionPost'
import { DiscussionPostChannel } from '../../../channels/discussionPostChannel'
import { Loading } from '../../common/Loading'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { CacheContext } from '../Discussion'

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
  const { posts: cacheKey } = useContext(CacheContext)
  const { status, data } = useRequestQuery<{
    posts: DiscussionPostProps[]
  }>(cacheKey, { endpoint: endpoint, options: {} })
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
  const lastPostRef = useRef<HTMLDivElement>(null)

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
    if (!lastPostRef.current) {
      return
    }

    lastPostRef.current.scrollIntoView()
  }, [data])

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
        {iterations.map((iteration) => {
          return (
            <React.Fragment key={iteration.idx}>
              <div className="iteration-marker">
                <div className="info">
                  <GraphicalIcon icon="iteration" />
                  <strong>Iteration {iteration.idx}</strong>
                  was submitted
                </div>
                {/* TODO: Read this from Data */}
                <time>24 Jan 2020</time>
              </div>
              {iteration.posts.map((post) => {
                if (iterations[iterations.length - 1] === iteration) {
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
