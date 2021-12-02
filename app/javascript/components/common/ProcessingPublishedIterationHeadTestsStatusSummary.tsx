import React from 'react'
import { SubmissionTestsStatus } from '../types'
import { GraphicalIcon, Icon } from '.'

function Content({ testsStatus }: { testsStatus: SubmissionTestsStatus }) {
  switch (testsStatus) {
    case SubmissionTestsStatus.NOT_QUEUED:
    case SubmissionTestsStatus.QUEUED:
      return (
        <>
          <GraphicalIcon icon="spinner" />
          <div className="--status">Processing</div>
        </>
      )
    case SubmissionTestsStatus.PASSED:
      return (
        <Icon
          icon="golden-check"
          alt="This solution passes the tests of the latest version of this exercise"
        />
      )
    default:
      return (
        <>
          <div role="presentation" className="--dot"></div>
          <div className="--status">Failed</div>
        </>
      )
  }
}

export function ProcessingPublishedIterationHeadTestsStatusSummary({
  testsStatus,
}: {
  testsStatus: SubmissionTestsStatus
}): JSX.Element {
  if (testsStatus == SubmissionTestsStatus.CANCELLED) {
    return <></>
  }

  return (
    <div
      className={`c-iteration-processing-status --${testsStatus}`}
      role="status"
      aria-label="Processing status"
    >
      <Content testsStatus={testsStatus} />
    </div>
  )
}
