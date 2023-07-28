import React from 'react'
import { IterationStatus } from '../types'
import { GraphicalIcon } from '.'

function Content({ status }: { status: string }) {
  switch (status) {
    case 'processing':
      return (
        <>
          <GraphicalIcon icon="spinner" className="animate-spin-slow" />
          <div className="--status">Processing</div>
        </>
      )
    case 'failed':
      return (
        <>
          <div role="presentation" className="--dot"></div>
          <div className="--status">Failed</div>
        </>
      )
    default:
      return (
        <>
          <div role="presentation" className="--dot"></div>
          <div className="--status">Passed</div>
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
}): JSX.Element {
  if (
    iterationStatus == IterationStatus.DELETED ||
    iterationStatus == IterationStatus.UNTESTED
  ) {
    return <></>
  }
  const status = transformStatus(iterationStatus)

  return (
    <div
      className={`c-iteration-processing-status --${status}`}
      role="status"
      aria-label="Processing status"
    >
      <Content status={status} />
    </div>
  )
}
