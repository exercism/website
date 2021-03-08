import React from 'react'
import { MentorDiscussion } from '../../types'
import { MentorDiscussionSummary } from '../../common/MentorDiscussionSummary'

export const DiscussionList = ({
  discussions,
}: {
  discussions: MentorDiscussion[]
}): JSX.Element => {
  if (discussions.length === 0) {
    return (
      <div className="no-discussions">
        <h3>Mentoring discussions</h3>
        <p>
          Your discussions with mentors for this exercise will appear here once
          started.
        </p>
      </div>
    )
  }

  return (
    <div className="discussions">
      <h3>Mentoring discussions</h3>
      {discussions.map((discussion) => (
        <MentorDiscussionSummary key={discussion.id} {...discussion} />
      ))}
    </div>
  )
}
