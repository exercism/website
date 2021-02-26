import React from 'react'
import { AnalyzerFeedback as AnalyzerFeedbackProps } from '../Session'

export const AnalyzerFeedback = ({
  summary,
  comments,
}: AnalyzerFeedbackProps): JSX.Element => {
  return (
    <div className="feedback">
      {comments.map((comment) => (
        <div className="comment">
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
