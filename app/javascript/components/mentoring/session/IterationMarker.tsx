import React from 'react'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { timeFormat } from '../../../utils/time'
import { Iteration, Partner } from '../Session'
import { AutomatedFeedbackSummary } from './AutomatedFeedbackSummary'

export const IterationMarker = ({
  iteration,
  student,
}: {
  iteration: Iteration
  student: Partner
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
      {iteration.automatedFeedback ? (
        <AutomatedFeedbackSummary
          student={student}
          automatedFeedback={iteration.automatedFeedback}
        />
      ) : null}
    </React.Fragment>
  )
}
