import React, { useCallback } from 'react'
import { TestRunStatus, TestRun, Test } from './types'
import { TestsList } from './TestsList'

export function TestRunSummaryContent({
  testRun,
  onCancel,
}: {
  testRun: TestRun
  onCancel: () => void
}) {
  switch (testRun.status) {
    case TestRunStatus.PASS:
    case TestRunStatus.FAIL:
      return <TestsList tests={testRun.tests} />
    case TestRunStatus.ERROR:
      return (
        <div>
          <p>An error occurred</p>
          <p>We got the following error message when we ran your code:</p>
          <p>{testRun.message}</p>
        </div>
      )
    case TestRunStatus.OPS_ERROR:
      return (
        <div>
          <p>An error occurred</p>
          <p>{testRun.message}</p>
        </div>
      )
    case TestRunStatus.TIMEOUT:
      return (
        <div>
          <p>Tests timed out</p>
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
