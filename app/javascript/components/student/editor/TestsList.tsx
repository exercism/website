import React from 'react'
import { TestSummary } from './TestSummary'
import { TestStatus, Test } from './TestRunSummary'

function Overview({ tests }: { tests: Test[] }) {
  const passed = tests.filter((test) => test.status === TestStatus.PASS).length
  const failed = passed === tests.length ? 0 : 1
  const skipped = tests.length - (passed + failed)

  return (
    <p>
      {passed} passed, {failed} failed, {skipped} skipped
    </p>
  )
}

export function TestsList({ tests }: { tests: Test[] }) {
  const firstFailedTestIdx = tests.findIndex(
    (test) =>
      test.status === TestStatus.FAIL || test.status === TestStatus.ERROR
  )
  const testsToShow =
    firstFailedTestIdx === -1 ? tests : tests.slice(0, firstFailedTestIdx + 1)

  return (
    <div>
      <Overview tests={tests} />
      {testsToShow.map((test) => {
        return <TestSummary key={test.name} test={test} />
      })}
    </div>
  )
}
