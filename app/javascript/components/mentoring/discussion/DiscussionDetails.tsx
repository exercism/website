import React, { useState } from 'react'
import { Student, Iteration, MentorDiscussion } from '../../types'
import { FinishedWizard, ModalStep } from './FinishedWizard'
import { DiscussionPostList } from './DiscussionPostList'
import { QueryStatus } from 'react-query'

export const DiscussionDetails = ({
  discussion,
  iterations,
  student,
  userHandle,
  onIterationScroll,
  status,
}: {
  discussion: MentorDiscussion
  iterations: readonly Iteration[]
  student: Student
  userHandle: string
  onIterationScroll: (iteration: Iteration) => void
  status: QueryStatus
}): JSX.Element => {
  const [defaultWizardStep, setDefaultWizardStep] = useState<ModalStep>(
    discussion.isFinished ? 'finish' : 'mentorAgain'
  )

  return (
    <div className="discussion">
      <DiscussionPostList
        iterations={iterations}
        userIsStudent={false}
        discussionUuid={discussion.uuid}
        userHandle={userHandle}
        onIterationScroll={onIterationScroll}
        status={status}
      />
      {discussion.isFinished ? (
        <FinishedWizard student={student} defaultStep={defaultWizardStep} />
      ) : null}
    </div>
  )
}
