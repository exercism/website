import React, { useState } from 'react'
import { Student, StudentMentorRelationship } from '../Session'
import { Iteration, MentorDiscussion as Discussion } from '../../types'
import { FinishedWizard, ModalStep } from './FinishedWizard'
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
  const [defaultStep, setDefaultStep] = useState<ModalStep>(
    discussion.isFinished ? 'finish' : 'mentorAgain'
  )

  return (
    <React.Fragment>
      <DiscussionPostList
        endpoint={discussion.links.posts}
        iterations={iterations}
        userIsStudent={false}
        discussionId={discussion.id}
        userId={userId}
      />
      {discussion.isFinished ? (
        <FinishedWizard
          student={student}
          relationship={relationship}
          defaultStep={defaultStep}
        />
      ) : null}
    </React.Fragment>
  )
}
