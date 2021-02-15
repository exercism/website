import React from 'react'
import {
  Discussion,
  Iteration,
  Student,
  StudentMentorRelationship,
} from '../Session'
import { FinishedWizard } from './FinishedWizard'
import { DiscussionPostList } from './DiscussionPostList'

export const DiscussionDetails = ({
  discussion,
  iterations,
  student,
  relationship,
  userId,
}: {
  discussion: Discussion
  iterations: readonly Iteration[]
  student: Student
  relationship: StudentMentorRelationship
  userId: number
}): JSX.Element => {
  return (
    <React.Fragment>
      <DiscussionPostList
        endpoint={discussion.links.posts}
        iterations={iterations}
        student={student}
        discussionId={discussion.id}
        userId={userId}
      />
      {discussion.isFinished ? (
        <FinishedWizard student={student} relationship={relationship} />
      ) : null}
    </React.Fragment>
  )
}
