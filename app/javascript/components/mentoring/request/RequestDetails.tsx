import React from 'react'
import { DiscussionPost } from '../discussion/DiscussionPost'
import { Iteration, Student } from '../Session'
import { MentoringRequest } from '../../types'
import { IterationMarker } from '../session/IterationMarker'

export const RequestDetails = ({
  iterations,
  student,
  request,
}: {
  iterations: readonly Iteration[]
  student: Student
  request: MentoringRequest
  userId: number
}): JSX.Element => {
  const latestIteration = iterations[iterations.length - 1]
  return (
    /* TODO: This wrapper is needed to make the styling correct. Maybe unscope the iteration marker? */
    <div className="discussion">
      <IterationMarker iteration={latestIteration} userIsStudent={false} />
      <DiscussionPost
        id={-1}
        authorId={-1}
        iterationIdx={latestIteration.idx}
        authorHandle={student.handle}
        authorAvatarUrl={student.avatarUrl}
        byStudent
        contentMarkdown={request.comment}
        contentHtml={request.comment}
        updatedAt={request.updatedAt}
        links={{}}
      />
    </div>
  )
}
