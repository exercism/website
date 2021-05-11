import React, { useCallback } from 'react'
import { TestStatus, Test } from './types'
import { GraphicalIcon } from '../common/GraphicalIcon'

const statusLabels = {
  [TestStatus.PASS]: 'Passed',
  [TestStatus.FAIL]: 'Failed',
  [TestStatus.ERROR]: 'Failed',
}
const messageLabels = {
  [TestStatus.PASS]: null,
  [TestStatus.FAIL]: 'Test Failure',
  [TestStatus.ERROR]: 'Test Error',
}

export function TestSummary({
  test,
  defaultOpen,
}: {
  test: Test
  defaultOpen: boolean
}): JSX.Element {
  const isPresent = useCallback((str) => {
    return str !== undefined && str !== null && str !== ''
  }, [])

  return (
    <details
      className={`c-details c-test-summary ${test.status}`}
      open={defaultOpen}
    >
      <summary className="--summary">
        <div className="--status">
          <div className="--dot" />
          <span>{statusLabels[test.status]}</span>
        </div>
        <div className="--summary-details">
          <div className="--summary-idx">Test {test.index}</div>
          <div className="--summary-name">{test.name}</div>
        </div>
        <GraphicalIcon icon="chevron-right" className="--closed-icon" />
        <GraphicalIcon icon="chevron-down" className="--open-icon" />
      </summary>
      <div className="--explanation">
        {isPresent(test.testCode) ? (
          <div className="--info">
            <h3>Code Run</h3>
            <pre>{test.testCode}</pre>
          </div>
        ) : null}
        {isPresent(test.message) ? (
          <div className="--info">
            <h3>{messageLabels[test.status]}</h3>
            <pre>{test.message}</pre>
          </div>
        ) : null}
        {isPresent(test.output) ? (
          <div className="--info">
            <h3>Your Output</h3>
            <pre>{test.output}</pre>
          </div>
        ) : null}
      </div>
    </details>
  )
}
