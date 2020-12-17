import React from 'react'
import { fromNow } from '../../utils/time'

export type DiscussionPostProps = {
  id: number
  authorHandle: string
  authorAvatarUrl: string
  fromStudent: boolean
  contentHtml: string
  updatedAt: string
}

export const DiscussionPost = ({
  authorHandle,
  authorAvatarUrl,
  fromStudent,
  contentHtml,
  updatedAt,
}: DiscussionPostProps): JSX.Element => (
  <div>
    <img data-testid="author-avatar" src={authorAvatarUrl} />
    <p>{authorHandle}</p>
    {fromStudent ? <p>Student</p> : null}
    <div dangerouslySetInnerHTML={{ __html: contentHtml }} />
    <p>{fromNow(updatedAt)}</p>
  </div>
)
