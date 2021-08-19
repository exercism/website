import React from 'react'
import { Iteration } from '../../types'
import { IterationSummaryWithWebsockets } from '../../track/IterationSummary'

export const IterationHeader = ({
  iteration,
  isOutOfDate,
}: {
  iteration: Iteration
  isOutOfDate: boolean
}): JSX.Element => {
  return (
    <header className="iteration-header">
      <IterationSummaryWithWebsockets
        iteration={iteration}
        showSubmissionMethod={false}
        isOutOfDate={isOutOfDate}
        showTestsStatusAsButton={true}
        showFeedbackIndicator={false}
      />
    </header>
  )
}
