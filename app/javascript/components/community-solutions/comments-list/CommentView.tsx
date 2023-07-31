import React from 'react'
import { fromNow } from '../../../utils/time'
import { Avatar, Reputation, Icon, HandleWithFlair } from '../../common'
import { ViewingComponentType } from '../../common/ListItem'
import { SolutionComment } from '../../types'

export const CommentView = ({
  item: comment,
  onEdit,
}: ViewingComponentType<SolutionComment>): JSX.Element => {
  const isEditable = comment.links.edit

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
        {isEditable ? (
          <button type="button" className="edit-button" onClick={onEdit}>
            <Icon icon="edit" alt="Edit" />
            <span>Edit</span>
          </button>
        ) : null}
      </header>
      <div
        className="c-textual-content --small"
        dangerouslySetInnerHTML={{ __html: comment.contentHtml }}
      />
    </div>
  )
}
