import React from 'react'
import { Iteration, IterationStatus } from '../../types'
import { ProcessingStatusSummary } from '../../common/ProcessingStatusSummary'
import { TestsFailedButton } from './TestsFailedButton'

export const ProcessingStatusButton = ({
  iteration,
}: {
  iteration: Iteration
}): JSX.Element => {
  switch (iteration.status) {
    case IterationStatus.TESTS_FAILED:
      return (
        <TestsFailedButton endpoint={iteration.links.testRun}>
          <ProcessingStatusSummary iterationStatus={iteration.status} />
        </TestsFailedButton>
      )
    default:
      return <ProcessingStatusSummary iterationStatus={iteration.status} />
  }
}
