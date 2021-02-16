import React from 'react'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { RepresenterFeedback } from './RepresenterFeedback'
import { AnalyzerFeedback } from './AnalyzerFeedback'
import { Partner, AutomatedFeedback } from '../Session'

export const AutomatedFeedbackSummary = ({
  automatedFeedback,
  student,
  userId,
}: {
  automatedFeedback: AutomatedFeedback
  student: Partner
  userId: number
}): JSX.Element => {
  const addressedTo = userId === student.id ? 'You' : student.handle

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
