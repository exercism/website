import React from 'react'
import { MentorDiscussion } from '../../types'
import { MentorDiscussionSummary } from '../../common/MentorDiscussionSummary'

export const DiscussionList = ({
  discussions,
}: {
  discussions: readonly MentorDiscussion[]
}): JSX.Element => {
  if (discussions.length === 0) {
    return (
      <div className="no-discussions">
        <h3>Code Review Sessions</h3>
        <p>
          Your code review discussions with mentors for this exercise will
          appear here once started.
        </p>
      </div>
    )
  }

  return (
    <div className="discussions">
      <h3>Mentoring discussions</h3>
      {discussions.map((discussion) => (
        <MentorDiscussionSummary key={discussion.uuid} {...discussion} />
      ))}
    </div>
  )
}
