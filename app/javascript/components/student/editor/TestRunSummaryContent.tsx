import React, { useCallback } from 'react'
import { TestRunStatus } from '../Editor'
import { TestRun, Test } from './TestRunSummary'

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
      return (
        <div>
          {testRun.tests.map((test: Test) => (
            <p key={test.name}>
              name: {test.name}, status: {test.status}, output: {test.output}
            </p>
          ))}
        </div>
      )
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
