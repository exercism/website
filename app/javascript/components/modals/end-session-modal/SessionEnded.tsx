import React from 'react'
import { Discussion } from '../EndSessionModal'

export const SessionEnded = ({
  discussion,
}: {
  discussion: Discussion
}): JSX.Element => {
  return (
    <div>
      <p>You&apos;ve ended your discussion with {discussion.student.handle}.</p>
    </div>
  )
}
