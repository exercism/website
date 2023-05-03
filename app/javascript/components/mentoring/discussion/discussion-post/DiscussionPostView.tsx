import React from 'react'
import { DiscussionPostProps } from '../DiscussionPost'
import { shortFromNow } from '../../../../utils/time'
import { Avatar } from '../../../common/Avatar'
import { Icon } from '../../../common/Icon'
import { ViewingComponentType } from '../../../common/ListItem'
import { DiscussionPostContent } from './DiscussionPostContent'
import { HandleWithFlair } from '@/components/common/HandleWithFlair'

export const DiscussionPostView = ({
  onEdit,
  item: post,
  className = '',
  itemRef,
}: ViewingComponentType<DiscussionPostProps>): JSX.Element => {
  const isEditable = post.links.edit

  const classNames = [
    'post',
    'timeline-entry',
    isEditable ? '--editable' : '',
    className,
  ].filter((c) => c.length > 0)

  return (
    <div ref={itemRef} className={classNames.join(' ')}>
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
          <time>{shortFromNow(post.updatedAt)}</time>

          {isEditable ? (
            <button type="button" className="edit-button" onClick={onEdit}>
              <Icon icon="edit" alt="Edit" />
            </button>
          ) : null}
        </header>
        <DiscussionPostContent contentHtml={post.contentHtml} />
      </div>
    </div>
  )
}
