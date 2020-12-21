import React from 'react'
import { MarkdownEditor } from '../common/MarkdownEditor'

export const Scratchpad = ({
  discussionId,
}: {
  discussionId: number
}): JSX.Element => {
  return <MarkdownEditor contextId={`scratchpad-${discussionId}`} />
}
