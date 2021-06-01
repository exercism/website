import React, { useState } from 'react'
import { Student, Iteration, MentorDiscussion } from '../../types'
import { FinishedWizard, ModalStep } from './FinishedWizard'
import { DiscussionPostList } from './DiscussionPostList'

export const DiscussionDetails = ({
  discussion,
  iterations,
  student,
  userId,
}: {
  discussion: MentorDiscussion
  iterations: readonly Iteration[]
  student: Student
  userId: number
}): JSX.Element => {
  const [defaultWizardStep, setDefaultWizardStep] = useState<ModalStep>(
    discussion.isFinished ? 'finish' : 'mentorAgain'
  )

  return (
    <React.Fragment>
      <div className="discussion">
        <DiscussionPostList
          endpoint={discussion.links.posts}
          iterations={iterations}
          userIsStudent={false}
          discussionId={discussion.id}
          userId={userId}
        />
        {discussion.isFinished ? (
          <FinishedWizard student={student} defaultStep={defaultWizardStep} />
        ) : null}
      </div>
    </React.Fragment>
  )
}
