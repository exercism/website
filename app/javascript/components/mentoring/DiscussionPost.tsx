import React from 'react'
import { fromNow } from '../../utils/time'
import { EditDiscussionPost } from './EditDiscussionPost'

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
  <div>
    <img src={authorAvatarUrl} alt={`Avatar of ${authorHandle}`} />
    <p>{authorHandle}</p>
    {byStudent ? <p>Student</p> : null}
    <div dangerouslySetInnerHTML={{ __html: contentHtml }} />
    <p>{fromNow(updatedAt)}</p>
    {links.update ? (
      <EditDiscussionPost
        value={contentMarkdown}
        endpoint={links.update}
        contextId={`edit_${id}`}
      />
    ) : null}
  </div>
)
