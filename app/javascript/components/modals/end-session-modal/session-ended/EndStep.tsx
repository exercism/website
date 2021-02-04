import React from 'react'
import { Discussion } from '../../EndSessionModal'

export const EndStep = ({
  discussion,
  onReset,
}: {
  discussion: Discussion
  onReset: () => void
}): JSX.Element => {
  return (
    <div>
      {discussion.relationship.isFavorited ? (
        <p>{discussion.student.handle} is one of your favorites.</p>
      ) : (
        <p>Thanks for mentoring.</p>
      )}
      <button type="button" onClick={() => onReset()}>
        Change preferences
      </button>
    </div>
  )
}
