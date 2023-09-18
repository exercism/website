import React from 'react'
import { Avatar } from '@/components/common'
import type { RepresenterFeedback as Props } from '@/components/types'

export const RepresenterFeedback = ({
  html,
  author,
  editor,
}: Props): JSX.Element => {
  return (
    <div className="c-automated-feedback representer-feedback">
      <div className="feedback-header">
        <Avatar
          src={author.avatarUrl}
          handle={author.name}
          className="place-self-start"
        />
        <div className="info">
          <strong className="inline-block">{author.name}</strong>
          &nbsp;gave this feedback on a solution very similar to yours
          <EditedBy editor={editor} author={author} />:
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

export function EditedBy({
  author,
  editor,
}: Pick<Props, 'author' | 'editor'>): JSX.Element | null {
  if (!editor || editor.name === author.name) return null

  return (
    <em>
      &nbsp;(edited by <strong>{editor.name}</strong>)
    </em>
  )
}
