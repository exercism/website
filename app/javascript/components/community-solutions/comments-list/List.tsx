import React from 'react'
import { SolutionComment } from '../../types'
import { Comment } from './Comment'

export const List = ({
  comments,
}: {
  comments: readonly SolutionComment[]
}): JSX.Element => {
  return (
    <React.Fragment>
      {comments.map((comment) => (
        <Comment comment={comment} key={comment.uuid} />
      ))}
    </React.Fragment>
  )
}
