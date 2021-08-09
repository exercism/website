import React from 'react'
import { fromNow } from '../../utils/time'
import { Avatar, Reputation } from '../common'
import { SolutionComment } from '../types'

export const CommentsList = ({
  comments,
}: {
  comments: readonly SolutionComment[]
}): JSX.Element => {
  return (
    <React.Fragment>
      {comments.map((comment) => {
        return (
          <div className="comment" key={comment.uuid}>
            <header className="flex items-center mb-16">
              <Avatar
                src={comment.author.avatarUrl}
                handle={comment.author.handle}
              />
              <div className="flex flex-col">
                <div className="flex items-center">
                  <div className="text-h6 mr-8">{comment.author.handle}</div>
                  <Reputation value={comment.author.reputation} size="small" />
                </div>
                <div className="text-tetColor6 leading-160">
                  {fromNow(comment.updatedAt)}
                </div>
              </div>
            </header>
            <div
              className="c-textual-content --small"
              dangerouslySetInnerHTML={{ __html: comment.contentHtml }}
            />
          </div>
        )
      })}
    </React.Fragment>
  )
}
