import React from 'react'
import { fromNow } from '../../utils/time'

export type DiscussionPostProps = {
  id: number
  authorHandle: string
  authorAvatarUrl: string
  byStudent: boolean
  contentHtml: string
  updatedAt: string
}

export const DiscussionPost = ({
  authorHandle,
  authorAvatarUrl,
  byStudent,
  contentHtml,
  updatedAt,
}: DiscussionPostProps): JSX.Element => (
  <div>
    <img src={authorAvatarUrl} alt={`Avatar of ${authorHandle}`} />
    <p>{authorHandle}</p>
    {byStudent ? <p>Student</p> : null}
    <div dangerouslySetInnerHTML={{ __html: contentHtml }} />
    <p>{fromNow(updatedAt)}</p>
  </div>
)
