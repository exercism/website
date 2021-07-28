import React, { useCallback, forwardRef } from 'react'
import { DiscussionPostProps } from '../DiscussionPost'
import { shortFromNow } from '../../../../utils/time'
import { Avatar } from '../../../common/Avatar'
import { Icon } from '../../../common/Icon'
import { useHighlighting } from '../../../../utils/highlight'

export const DiscussionPostView = forwardRef<
  HTMLDivElement,
  { post: DiscussionPostProps; onEdit: () => void; className?: string }
>(({ onEdit, post, className = '' }, ref) => {
  const isEditable = post.links.edit
  const contentRef = useHighlighting<HTMLDivElement>()

  const handleEdit = useCallback(() => {
    onEdit()
  }, [onEdit])

  const classNames = [
    'post',
    'timeline-entry',
    isEditable ? '--editable' : '',
    className,
  ].filter((c) => c.length > 0)

  return (
    <div ref={ref} className={classNames.join(' ')}>
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
            <button type="button" className="edit-button" onClick={handleEdit}>
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
})
