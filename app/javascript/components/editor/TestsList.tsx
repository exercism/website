import React from 'react'
import pluralize from 'pluralize'
import { TestSummary } from './TestSummary'
import { TestStatus, Test } from './types'

export function TestsList({ tests }: { tests: Test[] }): JSX.Element {
  const firstFailedTestIdx = tests.findIndex(
    (test) =>
      test.status === TestStatus.FAIL || test.status === TestStatus.ERROR
  )
  const passed = tests.filter((test) => test.status === TestStatus.PASS)
  const failed = firstFailedTestIdx !== -1 ? [tests[firstFailedTestIdx]] : []
  const skipped = tests.length - (passed.length + failed.length)

  return (
    <div className="tests-list">
      <details>
        <summary>
          {passed.length} {pluralize('test', passed.length)} passed
        </summary>
        {passed.map((test) => (
          <TestSummary
            key={test.name}
            test={test}
            index={tests.indexOf(test) + 1}
          />
        ))}
      </details>
      <details open={true}>
        <summary>
          {failed.length} {pluralize('test', failed.length)} failed
        </summary>
        {failed.map((test) => (
          <TestSummary
            key={test.name}
            test={test}
            index={tests.indexOf(test) + 1}
          />
        ))}
      </details>
      <p>
        {skipped} {pluralize('test', skipped)} skipped
      </p>
    </div>
  )
}
