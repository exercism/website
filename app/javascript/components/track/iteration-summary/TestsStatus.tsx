import React from 'react'
import { TestRunStatus } from '../../student/Editor'

function Content({ testsStatus }: { testsStatus: TestRunStatus }) {
  switch (testsStatus) {
    case TestRunStatus.QUEUED:
      return (
        <>
          <svg role="presentation" className="icon">
            <use xlinkHref="#loading" />
          </svg>
          <div className="status">Queued</div>
        </>
      )
    case TestRunStatus.PASS:
      return (
        <>
          <div className="dot"></div>
          <div className="status">Passed</div>
        </>
      )
    case TestRunStatus.FAIL:
      return (
        <>
          <div className="dot"></div>
          <div className="status">Failed</div>
        </>
      )
    case TestRunStatus.OPS_ERROR:
    case TestRunStatus.ERROR:
      return (
        <>
          <div className="dot"></div>
          <div className="status">Errored</div>
        </>
      )
    case TestRunStatus.CANCELLED:
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

export function TestsStatus({ testsStatus }: { testsStatus: TestRunStatus }) {
  return (
    <div className="tests">
      <Content testsStatus={testsStatus} />
    </div>
  )
}
