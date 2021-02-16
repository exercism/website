import React from 'react'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { RepresenterFeedback } from './RepresenterFeedback'
import { AnalyzerFeedback } from './AnalyzerFeedback'
import { Partner, AutomatedFeedback } from '../Session'

export const AutomatedFeedbackSummary = ({
  automatedFeedback,
  student,
}: {
  automatedFeedback: AutomatedFeedback
  student: Partner
}): JSX.Element => {
  return (
    <details className="c-details auto-feedback">
      <summary>
        <GraphicalIcon icon="alert-circle" className="info-icon" />
        <div className="info">{student.handle} received automated feedback</div>
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
