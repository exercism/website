import React from 'react'
import pluralize from 'pluralize'
import { TestSummary } from './TestSummary'
import { TestStatus, Test } from './types'
import { GraphicalIcon } from '../common/GraphicalIcon'

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
      <details className="tests-group c-details">
        <summary className="tests-group-summary">
          <GraphicalIcon icon="passed-check-circle" className="indicator" />
          {passed.length} {pluralize('test', passed.length)} passed
          <GraphicalIcon icon="chevron-right" className="--closed-icon" />
          <GraphicalIcon icon="chevron-down" className="--open-icon" />
        </summary>
        {passed.map((test) => (
          <TestSummary
            key={test.name}
            test={test}
            index={tests.indexOf(test) + 1}
          />
        ))}
      </details>
      <details open={true} className="tests-group c-details">
        <summary className="tests-group-summary">
          <GraphicalIcon icon="failed-check-circle" className="indicator" />
          {failed.length} {pluralize('test', failed.length)} failed
          <GraphicalIcon icon="chevron-right" className="--closed-icon" />
          <GraphicalIcon icon="chevron-down" className="--open-icon" />
        </summary>
        {failed.map((test) => (
          <TestSummary
            key={test.name}
            test={test}
            index={tests.indexOf(test) + 1}
          />
        ))}
      </details>
      <div className="tests-group">
        <div className="tests-group-summary">
          <GraphicalIcon icon="skipped-check-circle" className="indicator" />
          {skipped} {pluralize('test', skipped)} skipped
        </div>
      </div>
    </div>
  )
}
