import React, { useState } from 'react'
import { Student, Iteration, MentorDiscussion } from '../../types'
import { FinishedWizard, ModalStep } from './FinishedWizard'
import { DiscussionPostList } from './DiscussionPostList'

export const DiscussionDetails = ({
  discussion,
  iterations,
  student,
  userHandle,
  onIterationScroll,
}: {
  discussion: MentorDiscussion
  iterations: readonly Iteration[]
  student: Student
  userHandle: string
  onIterationScroll: (iteration: Iteration) => void
}): JSX.Element => {
  const [defaultWizardStep, setDefaultWizardStep] = useState<ModalStep>(
    discussion.isFinished ? 'finish' : 'mentorAgain'
  )

  return (
    <div className="discussion">
      <DiscussionPostList
        endpoint={discussion.links.posts}
        iterations={iterations}
        userIsStudent={false}
        discussionUuid={discussion.uuid}
        userHandle={userHandle}
        onIterationScroll={onIterationScroll}
      />
      {discussion.isFinished ? (
        <FinishedWizard student={student} defaultStep={defaultWizardStep} />
      ) : null}
    </div>
  )
}
