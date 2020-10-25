import React, { useCallback } from 'react'
import { TestStatus } from './TestRunSummary'

export function TestSummary({ test }: { test: Test }) {
  const statusLabels = {
    [TestStatus.PASS]: 'Passed',
    [TestStatus.FAIL]: 'Failed',
  }

  return (
    <div>
      <p>
        {statusLabels[test.status]}: {test.name}
      </p>
      {test.output && <p>Output: {test.output}</p>}
    </div>
  )
}
