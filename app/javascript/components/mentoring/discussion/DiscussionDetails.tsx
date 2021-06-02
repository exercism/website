import React, { useState } from 'react'
import { Student, Iteration, MentorDiscussion } from '../../types'
import { FinishedWizard, ModalStep } from './FinishedWizard'
import { DiscussionPostList } from './DiscussionPostList'

export const DiscussionDetails = ({
  discussion,
  iterations,
  student,
  userId,
  onIterationScroll,
}: {
  discussion: MentorDiscussion
  iterations: readonly Iteration[]
  student: Student
  userId: number
  onIterationScroll: (iteration: Iteration) => void
}): JSX.Element => {
  const [defaultWizardStep, setDefaultWizardStep] = useState<ModalStep>(
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
        onIterationScroll={onIterationScroll}
      />
      {discussion.isFinished ? (
        <FinishedWizard student={student} defaultStep={defaultWizardStep} />
      ) : null}
    </React.Fragment>
  )
}
