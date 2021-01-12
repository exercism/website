import React, { useRef, useLayoutEffect } from 'react'
import { fromNow } from '../../../utils/time'
import { EditDiscussionPost } from './EditDiscussionPost'
import { Avatar } from '../../common/Avatar'
import { highlightBlock } from '../../../utils/highlight'

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
}: DiscussionPostProps): JSX.Element => {
  const contentRef = useRef<HTMLDivElement | null>(null)

  useLayoutEffect(() => {
    if (!contentRef.current) {
      return
    }

    contentRef.current
      .querySelectorAll<HTMLElement>('pre code')
      .forEach((block) => {
        highlightBlock(block)
      })
  }, [contentRef])

  return (
    <div className="post">
      <header className="post-header">
        <Avatar handle={authorHandle} src={authorAvatarUrl} />
        <div className="handle">{authorHandle}</div>
        {byStudent ? <div className="tag">Student</div> : null}
      </header>
      <div
        className="post-content c-textual-content --small"
        ref={contentRef}
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
}
