import React from 'react'
import { TestSummary } from './TestSummary'
import { TestStatus, Test } from './TestRunSummary'

export function TestsList({ tests }: { tests: Test[] }) {
  const firstFailedTestIdx = tests.findIndex(
    (test) =>
      test.status === TestStatus.FAIL || test.status === TestStatus.ERROR
  )
  const testsToShow = tests.slice(0, firstFailedTestIdx + 1)

  return (
    <div>
      {testsToShow.map((test) => {
        return <TestSummary key={test.name} test={test} />
      })}
    </div>
  )
}
