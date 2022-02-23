import React from 'react'
import { TestStatus, Test } from './types'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { TestsGroup, TestWithToggle } from './TestsGroup'
import pluralize from 'pluralize'
import { TestSummary } from './TestSummary'

const Tests = ({
  tests,
  language,
}: {
  tests: TestWithToggle[]
  language: string
}): JSX.Element => {
  return (
    <>
      {tests.map((test, i) => (
        <TestSummary
          key={i}
          test={test}
          defaultOpen={test.defaultOpen}
          language={language}
        />
      ))}
    </>
  )
}

const Title = ({
  status,
  tests,
}: {
  status: string
  tests: TestWithToggle[]
}): JSX.Element => {
  return (
    <>
      {tests.length} {pluralize('test', tests.length)} {status}
    </>
  )
}

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
    <div className="tests-grouped-by-status">
      <TestsGroup tests={passed}>
        <TestsGroup.Header>
          <GraphicalIcon icon="passed-check-circle" className="indicator" />
          <Title tests={passed} status="passed" />
          <GraphicalIcon icon="chevron-right" className="--closed-icon" />
          <GraphicalIcon icon="chevron-down" className="--open-icon" />
        </TestsGroup.Header>
        <Tests tests={passed} language={language} />
      </TestsGroup>
      <TestsGroup tests={failed} open={true}>
        <TestsGroup.Header>
          <GraphicalIcon icon="failed-check-circle" className="indicator" />
          <Title tests={failed} status="failed" />
          <GraphicalIcon icon="chevron-right" className="--closed-icon" />
          <GraphicalIcon icon="chevron-down" className="--open-icon" />
        </TestsGroup.Header>
        <Tests tests={failed} language={language} />
      </TestsGroup>
    </div>
  )
}
