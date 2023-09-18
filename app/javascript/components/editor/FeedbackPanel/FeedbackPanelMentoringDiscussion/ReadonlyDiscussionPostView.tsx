import React from 'react'
import { shortFromNow } from '@/utils/time'
import { Avatar } from '@/components/common'
import { DiscussionPostContent } from '@/components/mentoring/discussion/discussion-post/DiscussionPostContent'
import { DiscussionPostProps } from '@/components/mentoring/discussion/DiscussionPost'
import { ReadonlyIterationMarker } from '.'

export function ReadonlyDiscussionPostView({
  post,
  className = '',
  prevIterationIdx,
}: {
  post: DiscussionPostProps
  className?: string
  prevIterationIdx: number
}): JSX.Element {
  const classNames = ['post', 'timeline-entry', className].filter(
    (c) => c.length > 0
  )

  return (
    <>
      {prevIterationIdx === post.iterationIdx ? null : (
        <ReadonlyIterationMarker idx={post.iterationIdx} />
      )}
      <div className={classNames.join(' ')}>
        <Avatar
          handle={post.authorHandle}
          src={post.authorAvatarUrl}
          className="timeline-marker"
        />
        <div className="timeline-content">
          <header className="timeline-entry-header">
            <div className="author">{post.authorHandle}</div>
            <time>{shortFromNow(post.updatedAt)}</time>
          </header>
          <DiscussionPostContent contentHtml={post.contentHtml} />
        </div>
      </div>
    </>
  )
}
