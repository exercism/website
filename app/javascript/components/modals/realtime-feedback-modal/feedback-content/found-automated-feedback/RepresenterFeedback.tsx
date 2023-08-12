import React from 'react'
import { Avatar } from '@/components/common'
import { EditedBy } from '@/components/student/iterations-list/RepresenterFeedback'
import { BLOCKQUOTE } from './AnalyzerFeedback'
import type { RepresenterFeedback as Props } from '@/components/types'

export const RepresenterFeedback = ({
  html,
  author,
  editor,
}: Props): JSX.Element => {
  return (
    <div className="c-automated-feedback representer-feedback">
      <div className={`comment ${BLOCKQUOTE}`}>
        <div
          className="c-textual-content --small"
          dangerouslySetInnerHTML={{ __html: html }}
        />
      </div>
      <div className="feedback-header">
        <Avatar
          src={author.avatarUrl}
          handle={author.name}
          className="place-self-start"
        />
        <div className="info">
          <strong className="inline-block">{author.name}</strong>
          &nbsp;gave this feedback on a solution very similar to yours
          <EditedBy editor={editor} author={author} />.
        </div>
      </div>
    </div>
  )
}
