import React from 'react'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { RepresenterFeedback } from './RepresenterFeedback'
import { AnalyzerFeedback } from './AnalyzerFeedback'
import { Student, AutomatedFeedback } from '../Session'

export const AutomatedFeedbackSummary = ({
  automatedFeedback,
  userIsStudent,
}: {
  automatedFeedback: AutomatedFeedback
  userIsStudent: boolean
}): JSX.Element => {
  const addressedTo = userIsStudent ? 'You' : 'Your student'

  return (
    <details className="c-details auto-feedback">
      <summary>
        <GraphicalIcon icon="alert-circle" className="info-icon" />
        <div className="info">{addressedTo} received automated feedback</div>
        <GraphicalIcon icon="chevron-right" className="--closed-icon" />
        <GraphicalIcon icon="chevron-down" className="--open-icon" />
      </summary>
      {automatedFeedback.mentor ? (
        <RepresenterFeedback {...automatedFeedback.mentor} />
      ) : null}
      {automatedFeedback.analyzer ? (
        <AnalyzerFeedback {...automatedFeedback.analyzer} />
      ) : null}
    </details>
  )
}
