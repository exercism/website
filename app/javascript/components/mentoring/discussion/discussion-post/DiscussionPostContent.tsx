import React, { useEffect, useRef } from 'react'
import { highlightAll } from '../../../../utils/highlight'

export const DiscussionPostContent = ({
  contentHtml,
}: {
  contentHtml: string
}): JSX.Element => {
  const contentRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!contentRef.current) {
      return
    }

    highlightAll(contentRef.current)
  }, [contentHtml])

  return (
    <div
      className="post-content c-textual-content --small"
      ref={contentRef}
      dangerouslySetInnerHTML={{ __html: contentHtml }}
    />
  )
}
