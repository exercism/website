import React from 'react'
import { EmptyList } from './comments-list/EmptyList'
import { List } from './comments-list/List'
import { SolutionComment } from '../types'

export const CommentsList = ({
  comments,
}: {
  comments: readonly SolutionComment[]
}): JSX.Element => {
  if (comments.length === 0) {
    return <EmptyList />
  }

  return <List comments={comments} />
}
