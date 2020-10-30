import React from 'react'
import { SubmissionTestsStatus } from '../../student/Editor'

function Content({ testsStatus }: { testsStatus: SubmissionTestsStatus }) {
  switch (testsStatus) {
    case SubmissionTestsStatus.QUEUED:
      return (
        <>
          <svg role="presentation" className="icon">
            <use xlinkHref="#loading" />
          </svg>
          <div className="status">Queued</div>
        </>
      )
    case SubmissionTestsStatus.PASSED:
      return (
        <>
          <div className="dot"></div>
          <div className="status">Passed</div>
        </>
      )
    case SubmissionTestsStatus.FAILED:
      return (
        <>
          <div className="dot"></div>
          <div className="status">Failed</div>
        </>
      )
    case SubmissionTestsStatus.ERRORED:
    case SubmissionTestsStatus.EXCEPTIONED:
      return (
        <>
          <div className="dot"></div>
          <div className="status">Errored</div>
        </>
      )
    case SubmissionTestsStatus.CANCELLED:
      return (
        <>
          <div className="dot"></div>
          <div className="status">Cancelled</div>
        </>
      )
    default:
      return null
  }
}

export function TestsStatusSummary({
  testsStatus,
}: {
  testsStatus: TestRunStatus
}) {
  return (
    <div className="tests">
      <Content testsStatus={testsStatus} />
    </div>
  )
}
