import React, { useCallback } from 'react'
import { TestStatus, Test } from './types'

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
  index,
}: {
  test: Test
  index: number
}): JSX.Element {
  const isPresent = useCallback((str) => {
    return str !== undefined && str !== null && str !== ''
  }, [])

  return (
    <details
      className={`c-test-summary ${test.status}`}
      open={test.status === TestStatus.FAIL || test.status === TestStatus.ERROR}
    >
      <summary>
        <div className="--status">{statusLabels[test.status]}</div>
        <div className="--summary-details">
          <div className="--summary-idx">Test {index}</div>
          <div className="--summary-name">{test.name}</div>
        </div>
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
