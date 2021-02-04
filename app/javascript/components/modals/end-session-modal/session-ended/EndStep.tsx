import React from 'react'
import { Discussion } from '../../EndSessionModal'

export const EndStep = ({
  discussion,
}: {
  discussion: Discussion
}): JSX.Element => {
  if (discussion.relationship.isFavorited) {
    return <p>{discussion.student.handle} is one of your favorites.</p>
  } else {
    return <p>Thanks for mentoring.</p>
  }
}
