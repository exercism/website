import React from 'react'
import { Iteration, IterationStatus } from '../../types'
import { ProcessingStatusSummary } from '../../common/ProcessingStatusSummary'
import { TestRunStatusButton } from './TestRunStatusButton'

export const ProcessingStatusButton = ({
  iteration,
}: {
  iteration: Iteration
}): JSX.Element => {
  switch (iteration.status) {
    case IterationStatus.DELETED:
      return <></>
    case IterationStatus.TESTS_FAILED:
    case IterationStatus.ESSENTIAL_AUTOMATED_FEEDBACK:
    case IterationStatus.ACTIONABLE_AUTOMATED_FEEDBACK:
    case IterationStatus.NON_ACTIONABLE_AUTOMATED_FEEDBACK:
    case IterationStatus.CELEBRATORY_AUTOMATED_FEEDBACK:
    case IterationStatus.NO_AUTOMATED_FEEDBACK:
      return (
        <TestRunStatusButton endpoint={iteration.links.testRun}>
          <ProcessingStatusSummary iterationStatus={iteration.status} />
        </TestRunStatusButton>
      )
    default:
      return <ProcessingStatusSummary iterationStatus={iteration.status} />
  }
}
