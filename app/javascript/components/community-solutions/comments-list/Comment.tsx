import React, { forwardRef } from 'react'
import { DiscussionPostView } from './discussion-post/DiscussionPostView'
import { DiscussionPostEdit } from './discussion-post/DiscussionPostEdit'
import { ListItem, ListItemAction } from '../../common/ListItem'

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

export type DiscussionPostAction = ListItemAction

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
  ({ post, ...props }, ref) => {
    return (
      <ListItem<DiscussionPostProps>
        itemRef={ref}
        item={post}
        ViewingComponent={DiscussionPostView}
        EditingComponent={DiscussionPostEdit}
        {...props}
      />
    )
  }
)
