import React from 'react'
import { DiscussionPostProps } from '../DiscussionPost'
import { Avatar } from '../../../common/Avatar'
import { EditingComponentType } from '../../../common/ListItem'
import { EditListItemForm } from '../../../common/EditListItemForm'
import { HandleWithFlair } from '@/components/common/HandleWithFlair'

const DEFAULT_ERROR = new Error('Unable to edit post')

export const DiscussionPostEdit = ({
  item: post,
  onUpdate,
  onDelete,
  onCancel,
}: EditingComponentType<DiscussionPostProps>): JSX.Element => {
  return (
    <div className={`post timeline-entry`}>
      <Avatar
        handle={post.authorHandle}
        src={post.authorAvatarUrl}
        className="timeline-marker"
      />
      <div className="timeline-content">
        <header className="timeline-entry-header">
          <div className="author">
            <HandleWithFlair
              handle={post.authorHandle}
              flair={post.authorFlair}
            />
          </div>
        </header>
        <EditListItemForm<DiscussionPostProps>
          item={post}
          onUpdate={onUpdate}
          onDelete={onDelete}
          onCancel={onCancel}
          defaultError={DEFAULT_ERROR}
        />
      </div>
    </div>
  )
}
