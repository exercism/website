import React, { useCallback } from 'react'
import { TestStatus, Test } from './TestRunSummary'

export function TestSummary({ test }: { test: Test }) {
  const statusLabels = {
    [TestStatus.PASS]: 'Passed',
    [TestStatus.FAIL]: 'Failed',
    [TestStatus.ERROR]: 'Failed',
  }

  return (
    <details
      open={test.status === TestStatus.FAIL || test.status === TestStatus.ERROR}
    >
      <summary>
        {statusLabels[test.status]}: {test.name}
      </summary>
      {test.message && <p>Message: {test.message}</p>}
      {test.output && <p>Output: {test.output}</p>}
    </details>
  )
}
