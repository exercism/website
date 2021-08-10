import React from 'react'
import { CommentView } from './CommentView'
import { CommentEdit } from './CommentEdit'
import { ListItem, ListItemProps } from '../../common/ListItem'
import { SolutionComment } from '../../types'

type Props = { comment: SolutionComment } & Omit<
  ListItemProps<SolutionComment>,
  'item' | 'ViewingComponent' | 'EditingComponent'
>

export const Comment = ({ comment, ...props }: Props): JSX.Element => {
  return (
    <ListItem<SolutionComment>
      item={comment}
      ViewingComponent={CommentView}
      EditingComponent={CommentEdit}
      {...props}
    />
  )
}
