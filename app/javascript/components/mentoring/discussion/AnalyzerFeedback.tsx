import React from 'react'
import { AnalyzerFeedback as AnalyzerFeedbackProps } from '../Discussion'

export const AnalyzerFeedback = ({
  html,
  team,
}: AnalyzerFeedbackProps): JSX.Element => {
  return (
    <div className="feedback">
      <div className="c-textual-content --small">
        <p
          dangerouslySetInnerHTML={{
            __html: html,
          }}
        />
      </div>
      <div className="byline">
        <div className="name">by {team.name}</div>
      </div>
    </div>
  )
}
