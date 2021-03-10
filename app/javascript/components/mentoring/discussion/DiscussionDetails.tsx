import React, { useRef } from 'react'
import { Student, StudentMentorRelationship } from '../Session'
import { Iteration, MentorDiscussion } from '../../types'
import { FinishedWizard } from './FinishedWizard'
import { DiscussionPostList } from './DiscussionPostList'

export const DiscussionDetails = ({
  discussion,
  iterations,
  student,
  relationship,
  userId,
}: {
  discussion: MentorDiscussion
  iterations: readonly Iteration[]
  student: Student
  relationship: StudentMentorRelationship
  userId: number
}): JSX.Element => {
  const previouslyNotFinishedRef = useRef(!discussion.isFinished)
  const step = previouslyNotFinishedRef.current ? 'mentorAgain' : 'finish'

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
          defaultStep={step}
        />
      ) : null}
    </React.Fragment>
  )
}
