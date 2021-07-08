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
  { post: DiscussionPostProps; defaultAction?: DiscussionPostAction }
>(({ post, defaultAction = 'viewing' }, ref) => {
  const [action, setAction] = useState<DiscussionPostAction>(defaultAction)

  const handleEdit = useCallback(() => {
    setAction('editing')
  }, [])

  const handleEditCancel = useCallback(() => {
    setAction('viewing')
  }, [])

  const handleEditSuccess = useCallback(() => {
    setAction('viewing')
  }, [])

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
