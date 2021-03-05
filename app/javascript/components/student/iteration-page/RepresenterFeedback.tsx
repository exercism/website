import React from 'react'
import { Avatar } from '../../common'
import { RepresenterFeedback as Props } from '../../types'

export const RepresenterFeedback = ({ html, author }: Props): JSX.Element => {
  return (
    <div className="representer-feedback">
      <div className="feedback-header">
        <Avatar src={author.avatarUrl} handle={author.name} />
        <div className="info">
          <strong>{author.name}</strong> gave this feedback on a solution very
          similar to yours:
        </div>
      </div>
      <div className="comment">
        <div
          className="c-textual-content --small"
          dangerouslySetInnerHTML={{ __html: html }}
        />
      </div>
    </div>
  )
}
