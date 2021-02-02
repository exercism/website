import React from 'react'
import { SubmissionTestsStatus } from '../../editor/types'
import { GraphicalIcon } from '../../common'

function Content({ testsStatus }: { testsStatus: SubmissionTestsStatus }) {
  switch (testsStatus) {
    case SubmissionTestsStatus.QUEUED:
      return (
        <>
          <GraphicalIcon icon="spinner" />
          <div className="--status">Queued</div>
        </>
      )
    case SubmissionTestsStatus.PASSED:
      return (
        <>
          <div role="presentation" className="--dot"></div>
          <div className="--status">Passed</div>
        </>
      )
    case SubmissionTestsStatus.FAILED:
      return (
        <>
          <div role="presentation" className="--dot"></div>
          <div className="--status">Failed</div>
        </>
      )
    case SubmissionTestsStatus.ERRORED:
    case SubmissionTestsStatus.EXCEPTIONED:
      return (
        <>
          <div role="presentation" className="--dot"></div>
          <div className="--status">Errored</div>
        </>
      )
    case SubmissionTestsStatus.CANCELLED:
      return (
        <>
          <div role="presentation" className="--dot"></div>
          <div className="--status">Cancelled</div>
        </>
      )
    default:
      return null
  }
}

export function TestsStatusSummary({
  testsStatus,
}: {
  testsStatus: SubmissionTestsStatus
}) {
  return (
    <div
      className={`--tests --${testsStatus}`}
      role="status"
      aria-label="Test run status"
    >
      <Content testsStatus={testsStatus} />
    </div>
  )
}
