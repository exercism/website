import React from 'react'
import { IterationStatus } from '../IterationSummary'
import { GraphicalIcon } from '../../common'

function Content({ iterationStatus }: { iterationStatus: IterationStatus }) {
  switch (status) {
    case 'processing':
      return (
        <>
          <GraphicalIcon icon="spinner" />
          <div className="--status">Processing</div>
        </>
      )
    case 'failed':
      return (
        <>
          <div role="presentation" className="--dot"></div>
          <div className="--status">Tests Failed</div>
        </>
      )
    default:
      return (
        <>
          <div role="presentation" className="--dot"></div>
          <div className="--status">Tests Passed</div>
        </>
      )
  }
}

function transformStatus(iterationStatus: IterationStatus): string {
  switch (iterationStatus) {
    case IterationStatus.TESTING:
    case IterationStatus.ANALYZING:
      return 'processing'
    case IterationStatus.TESTS_FAILED:
      return 'failed'
    default:
      return 'passed'
  }
}

export function ProcessingStatusSummary({
  iterationStatus,
}: {
  iterationStatus: IterationStatus
}) {
  const status = transformStatus(iterationStatus)

  return (
    <div
      className={`--processing-status --${status}`}
      role="status"
      aria-label="Processing status"
    >
      <Content iterationStatus={iterationStatus} />
    </div>
  )
}
