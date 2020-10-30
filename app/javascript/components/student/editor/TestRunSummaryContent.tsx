import React, { useCallback } from 'react'
import { TestRunStatus, Submission, Test } from '../Editor'
import { TestsList } from './TestsList'

export function TestRunSummaryContent({
  submission,
  onCancel,
}: {
  submission: Submission
  onCancel: () => void
}) {
  switch (submission.testsStatus) {
    case TestRunStatus.PASS:
    case TestRunStatus.FAIL:
      return <TestsList tests={submission.testRun.tests} />
    case TestRunStatus.ERROR:
      return (
        <div>
          <p>An error occurred</p>
          <p>We got the following error message when we ran your code:</p>
          <p>{submission.testRun.message}</p>
        </div>
      )
    case TestRunStatus.OPS_ERROR:
      return (
        <div>
          <p>An error occurred</p>
          <p>{submission.testRun.message}</p>
        </div>
      )
    case TestRunStatus.QUEUED:
      const handleCancel = useCallback(() => {
        onCancel()
      }, [onCancel])

      return (
        <div>
          <p>We've queued your code and will run it shortly.</p>
          <button type="button" onClick={handleCancel}>
            Cancel
          </button>
        </div>
      )
    default:
      return null
  }
}
