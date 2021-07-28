import React, { forwardRef, useCallback } from 'react'
import { DiscussionPostView } from './discussion-post/DiscussionPostView'
import { DiscussionPostEdit } from './discussion-post/DiscussionPostEdit'

type DiscussionPostLinks = {
  edit?: string
  delete?: string
}

export type DiscussionPostProps = {
  uuid: string
  iterationIdx: number
  links: DiscussionPostLinks
  authorHandle: string
  authorAvatarUrl: string
  byStudent: boolean
  contentMarkdown: string
  contentHtml: string
  updatedAt: string
}

export type DiscussionPostAction = 'viewing' | 'editing'

type Props = {
  post: DiscussionPostProps
  action: DiscussionPostAction
  onUpdate?: (post: DiscussionPostProps) => void
  onDelete?: (post: DiscussionPostProps) => void
  onEdit?: () => void
  onEditCancel?: () => void
  className?: string
}

export const DiscussionPost = forwardRef<HTMLDivElement, Props>(
  (
    {
      post,
      action,
      onUpdate,
      onDelete,
      onEdit = () => null,
      onEditCancel = () => null,
      className = '',
    },
    ref
  ) => {
    const handleEdit = useCallback(() => {
      onEdit()
    }, [onEdit])
    const handleEditCancel = useCallback(() => {
      onEditCancel()
    }, [onEditCancel])

    const handleUpdate = useCallback(
      (post) => {
        if (!onUpdate) {
          return
        }

        onUpdate(post)
        onEditCancel()
      },
      [onEditCancel, onUpdate]
    )

    const handleDelete = useCallback(
      (post) => {
        if (!onDelete) {
          return
        }

        onDelete(post)
        onEditCancel()
      },
      [onDelete, onEditCancel]
    )

    switch (action) {
      case 'viewing':
        return (
          <DiscussionPostView
            post={post}
            onEdit={handleEdit}
            ref={ref}
            className={className}
          />
        )
      case 'editing':
        return (
          <DiscussionPostEdit
            post={post}
            onUpdate={onUpdate ? handleUpdate : undefined}
            onDelete={onDelete ? handleDelete : undefined}
            onCancel={handleEditCancel}
          />
        )
    }
  }
)
