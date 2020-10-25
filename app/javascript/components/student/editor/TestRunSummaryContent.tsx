import React, { useCallback } from 'react'
import { TestRunStatus } from '../Editor'
import { TestRun, Test } from './TestRunSummary'
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
    case TestRunStatus.OPS_ERROR:
      return <p>{testRun.message}</p>
    case TestRunStatus.QUEUED:
      const handleCancel = useCallback(
        (e) => {
          e.preventDefault()
          onCancel()
        },
        [onCancel]
      )

      return (
        <div>
          <p>We've queued your code and will run it shortly.</p>
          <button onClick={handleCancel}>Cancel</button>
        </div>
      )
    default:
      return <></>
  }
}
