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
  if (!request.comment) {
    throw 'request comment expected'
  }
  return (
    <div className="c-discussion-timeline">
      <IterationMarker iteration={iteration} userIsStudent={false} />
      {request.comment.contentHtml.length > 0 ? (
        <DiscussionPost action="viewing" post={request.comment} />
      ) : null}
    </div>
  )
}
