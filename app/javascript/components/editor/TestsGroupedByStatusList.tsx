import React from 'react'
import { TestStatus, Test } from './types'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { TestsGroup, TestWithToggle } from './TestsGroup'

export function TestsGroupedByStatusList({
  tests,
  language,
}: {
  tests: Test[]
  language: string
}): JSX.Element {
  const testsWithIndex = tests.map((test, i) => ({ index: i + 1, ...test }))
  const passed: TestWithToggle[] = testsWithIndex
    .filter((test) => test.status === TestStatus.PASS)
    .map((test) => {
      return { ...test, defaultOpen: false }
    })

  const failed: TestWithToggle[] = testsWithIndex
    .filter(
      (test) =>
        test.status === TestStatus.FAIL || test.status === TestStatus.ERROR
    )
    .map((test, i) => {
      return { ...test, defaultOpen: i === 0 }
    })

  return (
    <div className="tests-list">
      <TestsGroup tests={passed} language={language}>
        <TestsGroup.Header>
          <GraphicalIcon icon="passed-check-circle" className="indicator" />
          <TestsGroup.Title status="passed" />
          <GraphicalIcon icon="chevron-right" className="--closed-icon" />
          <GraphicalIcon icon="chevron-down" className="--open-icon" />
        </TestsGroup.Header>
        <TestsGroup.Tests />
      </TestsGroup>
      <TestsGroup open={true} tests={failed} language={language}>
        <TestsGroup.Header>
          <GraphicalIcon icon="failed-check-circle" className="indicator" />
          <TestsGroup.Title status="failed" />
          <GraphicalIcon icon="chevron-right" className="--closed-icon" />
          <GraphicalIcon icon="chevron-down" className="--open-icon" />
        </TestsGroup.Header>
        <TestsGroup.Tests />
      </TestsGroup>
    </div>
  )
}
