import React, { forwardRef } from 'react'
import { fromNow } from '../../../utils/time'
import { EditDiscussionPost } from './EditDiscussionPost'
import { Avatar } from '../../common/Avatar'
import { useHighlighting } from '../../../utils/highlight'

type DiscussionPostLinks = {
  update?: string
}

export type DiscussionPostProps = {
  id: number
  authorId: number
  iterationIdx: number
  links: DiscussionPostLinks
  authorHandle: string
  authorAvatarUrl: string
  byStudent: boolean
  contentMarkdown: string
  contentHtml: string
  updatedAt: string
}

export const DiscussionPost = forwardRef<HTMLDivElement, DiscussionPostProps>(
  (
    {
      id,
      links,
      authorHandle,
      authorAvatarUrl,
      byStudent,
      contentMarkdown,
      contentHtml,
      updatedAt,
    },
    ref
  ) => {
    const contentRef = useHighlighting<HTMLDivElement>()

    return (
      <div ref={ref} className="post">
        <header className="post-header">
          <div className="author">
            <Avatar handle={authorHandle} src={authorAvatarUrl} />
            <div className="handle">{authorHandle}</div>
            {byStudent ? <div className="tag">Student</div> : null}
          </div>
          {links.update ? (
            <EditDiscussionPost
              value={contentMarkdown}
              endpoint={links.update}
              contextId={`edit_${id}`}
            />
          ) : null}
        </header>
        <div
          className="post-content c-textual-content --small"
          ref={contentRef}
          dangerouslySetInnerHTML={{ __html: contentHtml }}
        />
        <time className="post-at">{fromNow(updatedAt)}</time>
      </div>
    )
  }
)
