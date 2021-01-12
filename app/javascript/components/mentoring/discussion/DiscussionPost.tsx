import React from 'react'
import { fromNow } from '../../../utils/time'
import { EditDiscussionPost } from './EditDiscussionPost'
import { Avatar } from '../../common/Avatar'

type DiscussionPostLinks = {
  update?: string
}

export type DiscussionPostProps = {
  id: number
  links: DiscussionPostLinks
  authorHandle: string
  authorAvatarUrl: string
  byStudent: boolean
  contentMarkdown: string
  contentHtml: string
  updatedAt: string
  iterationIdx: number
}

export const DiscussionPost = ({
  id,
  links,
  authorHandle,
  authorAvatarUrl,
  byStudent,
  contentMarkdown,
  contentHtml,
  updatedAt,
}: DiscussionPostProps): JSX.Element => (
  <div className="post">
    <header className="post-header">
      <Avatar handle={authorHandle} src={authorAvatarUrl} />
      <div className="handle">{authorHandle}</div>
      {byStudent ? <div className="tag">Student</div> : null}
    </header>
    <div
      className="post-content"
      dangerouslySetInnerHTML={{ __html: contentHtml }}
    />
    <time className="post-at">{fromNow(updatedAt)}</time>
    {links.update ? (
      <EditDiscussionPost
        value={contentMarkdown}
        endpoint={links.update}
        contextId={`edit_${id}`}
      />
    ) : null}
  </div>
)
