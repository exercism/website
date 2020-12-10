import React from 'react'
import pluralize from 'pluralize'
import { TestStatus, Test } from './types'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { TestsGroup } from './TestsGroup'

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
      <TestsGroup tests={passed}>
        <TestsGroup.Header>
          <GraphicalIcon icon="passed-check-circle" className="indicator" />
          {passed.length} {pluralize('test', passed.length)} passed
          <GraphicalIcon icon="chevron-right" className="--closed-icon" />
          <GraphicalIcon icon="chevron-down" className="--open-icon" />
        </TestsGroup.Header>
      </TestsGroup>
      <TestsGroup open={true} tests={failed}>
        <TestsGroup.Header>
          <GraphicalIcon icon="failed-check-circle" className="indicator" />
          {failed.length} {pluralize('test', failed.length)} failed
          <GraphicalIcon icon="chevron-right" className="--closed-icon" />
          <GraphicalIcon icon="chevron-down" className="--open-icon" />
        </TestsGroup.Header>
      </TestsGroup>
      <TestsGroup tests={[]}>
        <TestsGroup.Header>
          <GraphicalIcon icon="skipped-check-circle" className="indicator" />
          {skipped} {pluralize('test', skipped)} skipped
        </TestsGroup.Header>
      </TestsGroup>
    </div>
  )
}
