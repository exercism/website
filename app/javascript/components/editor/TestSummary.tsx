import React, { useCallback } from 'react'
import { TestStatus, Test } from './types'

export function TestSummary({ test }: { test: Test }) {
  const statusLabels = {
    [TestStatus.PASS]: 'Passed',
    [TestStatus.FAIL]: 'Failed',
    [TestStatus.ERROR]: 'Failed',
  }
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
          {/* TODO */}
          <div className="--summary-idx">Test 11</div>
          <div className="--summary-name">{test.name}</div>
        </div>
      </summary>
      <div className="--explanation">
        {/* TODO: If this is an error, the h3 should be "Test Error", otherwise it should be "Test Failure" */}
        {isPresent(test.testCode) ? (
          <div className="--info">
            <h3>Code Run</h3>
            <pre>{test.testCode}</pre>
          </div>
        ) : null}
        {isPresent(test.message) ? (
          <div className="--info">
            <h3>Test Error</h3>
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
