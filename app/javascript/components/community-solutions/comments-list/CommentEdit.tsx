import React from 'react'
import { Avatar } from '../../common/Avatar'
import { EditingComponentType } from '../../common/ListItem'
import { SolutionComment } from '../../types'
import { HandleWithFlair, Reputation } from '../../common'
import { fromNow } from '../../../utils/time'
import { EditListItemForm } from '../../common/EditListItemForm'

const DEFAULT_ERROR = new Error('Unable to edit comment')

export const CommentEdit = ({
  item: comment,
  onUpdate,
  onDelete,
  onCancel,
}: EditingComponentType<SolutionComment>): JSX.Element => {
  return (
    <div className="comment">
      <header className="flex items-center mb-16">
        <Avatar src={comment.author.avatarUrl} handle={comment.author.handle} />
        <div className="flex flex-col">
          <div className="flex items-center">
            <div className="text-h6 mr-8">
              <HandleWithFlair
                handle={comment.author.handle}
                flair={comment.author.flair}
              />
            </div>
            <Reputation value={comment.author.reputation} size="small" />
          </div>
          <div className="text-tetColor6 leading-160">
            {fromNow(comment.updatedAt)}
          </div>
        </div>
      </header>
      <EditListItemForm<SolutionComment>
        item={comment}
        onUpdate={onUpdate}
        onDelete={onDelete}
        onCancel={onCancel}
        defaultError={DEFAULT_ERROR}
      />
    </div>
  )
}
