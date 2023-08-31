import React, { useState } from 'react'
import { Iteration, MentorDiscussion } from '../../types'
import { FinishedWizard, ModalStep } from './FinishedWizard'
import { DiscussionPostList } from './DiscussionPostList'
import { QueryStatus } from '@tanstack/react-query'
import { FavoritableStudent } from '../session/FavoriteButton'

export const DiscussionDetails = ({
  discussion,
  iterations,
  student,
  setStudent,
  userHandle,
  onIterationScroll,
  status,
}: {
  discussion: MentorDiscussion
  iterations: readonly Iteration[]
  student: FavoritableStudent
  setStudent: (student: FavoritableStudent) => void
  userHandle: string
  onIterationScroll: (iteration: Iteration) => void
  status: QueryStatus
}): JSX.Element => {
  const [defaultWizardStep, setDefaultWizardStep] = useState<ModalStep>(
    discussion.isFinished ? 'finish' : 'mentorAgain'
  )

  return (
    <div className="c-discussion-timeline">
      <DiscussionPostList
        iterations={iterations}
        userIsStudent={false}
        discussionUuid={discussion.uuid}
        userHandle={userHandle}
        onIterationScroll={onIterationScroll}
        status={status}
      />
      {discussion.isFinished ? (
        <FinishedWizard
          student={student}
          defaultStep={defaultWizardStep}
          setStudent={setStudent}
        />
      ) : null}
    </div>
  )
}
