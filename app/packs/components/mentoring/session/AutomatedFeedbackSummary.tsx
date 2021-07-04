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
  const addressedTo = userIsStudent ? 'You' : 'Student'

  return (
    <div className="auto-feedback">
      <GraphicalIcon icon="automation" className="info-icon" />
      <div className="info">{addressedTo} received automated feedback</div>
      <GraphicalIcon icon="modal" className="modal-icon" />
    </div>
  )
}
