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
      open={test.status === TestStatus.FAIL || test.status === TestStatus.ERROR}
    >
      <summary>
        {statusLabels[test.status]}: {test.name}
      </summary>
      {isPresent(test.message) ? <p>Message: {test.message}</p> : null}
      {isPresent(test.output) ? <p>Output: {test.output}</p> : null}
    </details>
  )
}
