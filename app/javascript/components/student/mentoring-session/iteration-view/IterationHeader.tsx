import React from 'react'
import { Iteration } from '../../../types'
import {
  IterationSummaryWithWebsockets,
  IterationSummary,
} from '../../../track/IterationSummary'

export type Props = {
  iteration: Iteration
  isOutOfDate: boolean
}

export const IterationHeader = ({
  iteration,
  isOutOfDate,
}: Props): JSX.Element => {
  return (
    <header className="iteration-header">
      <IterationSummaryWithWebsockets
        iteration={iteration}
        showSubmissionMethod={false}
        OutOfDateNotice={
          isOutOfDate ? <IterationSummary.OutOfDateNotice /> : null
        }
        showTestsStatusAsButton={true}
        showFeedbackIndicator={false}
      />
    </header>
  )
}
