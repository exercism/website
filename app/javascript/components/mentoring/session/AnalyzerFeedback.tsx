import React from 'react'
import { AnalyzerFeedback as AnalyzerFeedbackProps } from '../../types'

export const AnalyzerFeedback = ({
  summary,
  comments,
}: AnalyzerFeedbackProps): JSX.Element => {
  return (
    <div className="feedback">
      {comments.map((comment, i) => (
        <div key={i} className="comment">
          <div
            key={comment.html}
            className="c-textual-content --small"
            dangerouslySetInnerHTML={{
              __html: comment.html,
            }}
          />
        </div>
      ))}
    </div>
  )
}
