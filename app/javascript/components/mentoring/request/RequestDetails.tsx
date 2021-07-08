import React from 'react'
import { DiscussionPost } from '../discussion/DiscussionPost'
import { MentorSessionRequest as Request, Iteration } from '../../types'
import { IterationMarker } from '../session/IterationMarker'

export const RequestDetails = ({
  iteration,
  request,
}: {
  iteration: Iteration
  request: Request
}): JSX.Element => {
  const markerPost = {
    uuid: 'iteration-marker',
    iterationIdx: iteration.idx,
    authorHandle: request.student.handle,
    authorAvatarUrl: request.student.avatarUrl,
    byStudent: true,
    contentMarkdown: request.comment,
    contentHtml: request.comment,
    updatedAt: request.updatedAt,
    links: {},
  }

  return (
    /* TODO: This wrapper is needed to make the styling correct. Maybe unscope the iteration marker? */
    <div className="discussion">
      <IterationMarker iteration={iteration} userIsStudent={false} />
      <DiscussionPost action="viewing" post={markerPost} />
    </div>
  )
}
