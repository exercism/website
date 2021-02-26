import React from 'react'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { timeFormat } from '../../../utils/time'
import { Iteration } from '../Session'
import { AutomatedFeedbackSummary } from './AutomatedFeedbackSummary'

export const IterationMarker = ({
  iteration,
  userIsStudent,
}: {
  iteration: Iteration
  userIsStudent: boolean
}): JSX.Element => {
  return (
    <React.Fragment>
      <div className="iteration-marker">
        <div className="info">
          <GraphicalIcon icon="iteration" />
          <strong>Iteration {iteration.idx}</strong>
          was submitted
        </div>
        <time>{timeFormat(iteration.createdAt, 'DD MMM YYYY')}</time>
      </div>
      {iteration.analyzerFeedback || iteration.representerFeedback ? (
        <AutomatedFeedbackSummary
          userIsStudent={userIsStudent}
          analyzerFeedback={iteration.analyzerFeedback}
          representerFeedback={iteration.representerFeedback}
        />
      ) : null}
    </React.Fragment>
  )
}
