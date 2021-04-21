import React from 'react'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { shortFromNow } from '../../../utils/time'
import { Iteration } from '../../types'
import { AutomatedFeedbackSummary } from './AutomatedFeedbackSummary'

export const IterationMarker = ({
  iteration,
  userIsStudent,
}: {
  iteration: Iteration
  userIsStudent: boolean
}): JSX.Element => {
  return (
    <>
      <div className="timeline-entry iteration-entry">
        <div className="timeline-marker">
          <GraphicalIcon icon="iteration" />
        </div>
        <div className="timeline-content">
          <div className="timeline-entry-header">
            <div className="info">
              <strong>Iteration {iteration.idx}</strong>
              was submitted
            </div>
            <time>{shortFromNow(iteration.createdAt)}</time>
          </div>
        </div>
      </div>
      {iteration.analyzerFeedback || iteration.representerFeedback ? (
        <AutomatedFeedbackSummary
          userIsStudent={userIsStudent}
          analyzerFeedback={iteration.analyzerFeedback}
          representerFeedback={iteration.representerFeedback}
        />
      ) : null}
    </>
  )
}
