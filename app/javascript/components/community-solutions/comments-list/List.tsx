import React from 'react'
import { QueryKey } from '@tanstack/react-query'
import { SolutionComment } from '../../types'
import { Comment } from './Comment'
import { useItemList } from '../../common/use-item-list'

export const List = ({
  comments,
  cacheKey,
}: {
  comments: readonly SolutionComment[]
  cacheKey: QueryKey
}): JSX.Element => {
  const {
    getItemAction,
    handleEdit,
    handleEditCancel,
    handleUpdate,
    handleDelete,
  } = useItemList<SolutionComment>(cacheKey)

  return (
    <React.Fragment>
      {comments.map((comment) => {
        return (
          <Comment
            key={comment.uuid}
            comment={comment}
            action={getItemAction(comment)}
            onEdit={handleEdit(comment)}
            onEditCancel={handleEditCancel}
            onUpdate={handleUpdate}
            onDelete={handleDelete}
          />
        )
      })}
    </React.Fragment>
  )
}
