import React, { forwardRef, useCallback, useState } from 'react'
import { DiscussionPostView } from './discussion-post/DiscussionPostView'
import { DiscussionPostEdit } from './discussion-post/DiscussionPostEdit'

type DiscussionPostLinks = {
  self?: string
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

type DiscussionPostAction = 'viewing' | 'editing'

export const DiscussionPost = forwardRef<
  HTMLDivElement,
  {
    post: DiscussionPostProps
    action: DiscussionPostAction
    onEdit?: () => void
    onEditCancel?: () => void
  }
>(({ post, action, onEdit = () => null, onEditCancel = () => null }, ref) => {
  const handleEdit = useCallback(() => {
    onEdit()
  }, [onEdit])
  const handleEditCancel = useCallback(() => {
    onEditCancel()
  }, [onEditCancel])

  const handleEditSuccess = useCallback(() => {
    onEditCancel()
  }, [onEditCancel])

  switch (action) {
    case 'viewing':
      return <DiscussionPostView post={post} onEdit={handleEdit} ref={ref} />
    case 'editing':
      return (
        <DiscussionPostEdit
          post={post}
          onSuccess={handleEditSuccess}
          onCancel={handleEditCancel}
        />
      )
  }
})
