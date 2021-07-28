import React, { useContext, useCallback } from 'react'
import { usePostHighlighting } from './usePostHighlighting'
import { queryCache, QueryStatus } from 'react-query'
import { DiscussionPost, DiscussionPostProps } from './DiscussionPost'
import { Loading } from '../../common/Loading'
import { Iteration } from '../../types'
import { IterationMarker } from '../session/IterationMarker'
import { PostsContext } from './PostsContext'
import { usePosts } from './discussion-post-list/use-posts'
import { usePostEditing } from './discussion-post-list/use-post-editing'
import {
  usePostScrolling,
  IterationWithRef,
} from './discussion-post-list/use-post-scrolling'
import { useListTrimming } from './discussion-post-list/use-list-trimming'
import { useChannel } from './discussion-post-list/use-channel'

export const DiscussionPostList = ({
  discussionUuid,
  iterations,
  userHandle,
  userIsStudent,
  onIterationScroll,
  status,
}: {
  discussionUuid: string
  iterations: readonly Iteration[]
  userHandle: string
  userIsStudent: boolean
  onIterationScroll: (iteration: Iteration) => void
  status: QueryStatus
}): JSX.Element | null => {
  const { cacheKey } = useContext(PostsContext)
  const posts = usePosts(iterations)
  const { highlightedPost, highlightedPostRef } = usePostHighlighting(
    posts,
    userHandle
  )
  const { editingPost, handleEdit, handleEditCancel } = usePostEditing()
  const { iterationsWithRef } = usePostScrolling({
    iterations: iterations,
    onScroll: onIterationScroll,
  })
  const iterationsToShow = useListTrimming<IterationWithRef>(iterationsWithRef)
  useChannel(discussionUuid, () => queryCache.invalidateQueries(cacheKey))

  const handleDelete = useCallback(
    (deleted) => {
      queryCache.setQueryData<{ posts: DiscussionPostProps[] }>(
        [cacheKey],
        (oldData) => {
          if (!oldData) {
            return { posts: [] }
          }

          return {
            posts: oldData.posts.filter((post) => post.uuid !== deleted.uuid),
          }
        }
      )
    },
    [cacheKey]
  )
  const handleUpdate = useCallback(
    (updated) => {
      queryCache.setQueryData<{ posts: DiscussionPostProps[] }>(
        [cacheKey],
        (oldData) => {
          if (!oldData) {
            return { posts: [updated] }
          }

          return {
            posts: oldData.posts.map((post) => {
              return post.uuid === updated.uuid ? updated : post
            }),
          }
        }
      )
    },
    [cacheKey]
  )

  if (status === 'loading') {
    return (
      <div role="status" aria-label="Discussion post list loading indicator">
        <Loading />
      </div>
    )
  }

  return (
    <>
      {iterationsToShow.map((iteration) => {
        return (
          <React.Fragment key={iteration.idx}>
            <IterationMarker
              iteration={iteration}
              userIsStudent={userIsStudent}
              ref={iteration.ref}
            />
            {iteration.posts?.map((post) => {
              return (
                <DiscussionPost
                  ref={highlightedPost === post ? highlightedPostRef : null}
                  key={post.uuid}
                  post={post}
                  action={editingPost === post ? 'editing' : 'viewing'}
                  onEdit={handleEdit(post)}
                  onEditCancel={handleEditCancel}
                  onUpdate={handleUpdate}
                  onDelete={handleDelete}
                />
              )
            })}
          </React.Fragment>
        )
      })}
    </>
  )
}
