import React, { useCallback } from 'react'
import { DiscussionPostProps } from '../DiscussionPost'
import { shortFromNow } from '../../../../utils/time'
import { Avatar } from '../../../common/Avatar'
import { Icon } from '../../../common/Icon'
import { useHighlighting } from '../../../../utils/highlight'
import { ViewingComponentType } from '../../../common/ListItem'

export const DiscussionPostView = ({
  onEdit,
  item: post,
  className = '',
  itemRef,
}: ViewingComponentType<DiscussionPostProps>) => {
  const isEditable = post.links.edit
  const contentRef = useHighlighting<HTMLDivElement>()

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
          <div className="author">{post.authorHandle}</div>
          <time>{shortFromNow(post.updatedAt)}</time>

          {isEditable ? (
            <button type="button" className="edit-button" onClick={onEdit}>
              <Icon icon="edit" alt="Edit" />
            </button>
          ) : null}
        </header>
        <div
          className="post-content c-textual-content --small"
          ref={contentRef}
          dangerouslySetInnerHTML={{ __html: post.contentHtml }}
        />
      </div>
    </div>
  )
}
