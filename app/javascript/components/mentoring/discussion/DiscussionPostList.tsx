import React, { useContext } from 'react'
import { usePostHighlighting } from './usePostHighlighting'
import { QueryStatus, useQueryClient } from '@tanstack/react-query'
import { DiscussionPostProps } from './DiscussionPost'
import { Loading } from '../../common/Loading'
import { Iteration } from '../../types'
import { IterationMarker } from '../session/IterationMarker'
import { PostsContext } from './PostsContext'
import { usePosts } from './discussion-post-list/use-posts'
import { useItemList } from '../../common/use-item-list'
import {
  usePostScrolling,
  IterationWithRef,
} from './discussion-post-list/use-post-scrolling'
import { useListTrimming } from './discussion-post-list/use-list-trimming'
import { useChannel } from './discussion-post-list/use-channel'
import { DiscussionPost } from './DiscussionPost'

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
  const queryClient = useQueryClient()
  const { cacheKey } = useContext(PostsContext)
  const posts = usePosts(iterations)
  const { highlightedPost, highlightedPostRef } = usePostHighlighting(
    posts,
    userHandle
  )
  const {
    getItemAction,
    handleEdit,
    handleEditCancel,
    handleUpdate,
    handleDelete,
  } = useItemList<DiscussionPostProps>([cacheKey])
  const { iterationsWithRef } = usePostScrolling({
    iterations: iterations,
    onScroll: onIterationScroll,
  })
  const iterationsToShow = useListTrimming<IterationWithRef>(iterationsWithRef)
  useChannel(discussionUuid, () => queryClient.invalidateQueries([cacheKey]))

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
                  key={post.uuid}
                  ref={highlightedPost === post ? highlightedPostRef : null}
                  post={post}
                  action={getItemAction(post)}
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
