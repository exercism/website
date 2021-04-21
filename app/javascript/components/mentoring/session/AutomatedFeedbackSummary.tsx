import React from 'react'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Icon } from '../../common/Icon'
import { RepresenterFeedback } from './RepresenterFeedback'
import { AnalyzerFeedback } from './AnalyzerFeedback'
import {
  AnalyzerFeedback as AnalyzerFeedbackProps,
  RepresenterFeedback as RepresenterFeedbackProps,
} from '../../types'

export const AutomatedFeedbackSummary = ({
  analyzerFeedback,
  representerFeedback,
  userIsStudent,
}: {
  analyzerFeedback?: AnalyzerFeedbackProps
  representerFeedback?: RepresenterFeedbackProps
  userIsStudent: boolean
}): JSX.Element => {
  const addressedTo = userIsStudent ? 'You' : 'Your student'

  return (
    <div className="timeline-entry auto-feedback">
      <div className="timeline-marker">
        <GraphicalIcon icon="alert-circle" className="info-icon" />
      </div>
      <details className="timeline-content c-details">
        <summary className="timeline-entry-header">
          <div className="info">{addressedTo} received automated feedback</div>
          <GraphicalIcon icon="chevron-right" className="--closed-icon" />
          <GraphicalIcon icon="chevron-down" className="--open-icon" />
        </summary>
        {representerFeedback ? (
          <RepresenterFeedback {...representerFeedback} />
        ) : null}
        {analyzerFeedback ? <AnalyzerFeedback {...analyzerFeedback} /> : null}
        {/* TODO: Fill out this URL */}
        <a href="#" className="more-info">
          Learn more about this feedback
          <Icon icon="external-link" alt="Opens in new tab" />
        </a>
      </details>
    </div>
  )
}
