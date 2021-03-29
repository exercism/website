import React from 'react'
import { TestRun } from './types'
import { TestsGroupList } from './TestsGroupList'

export const TestRunFailure = ({
  testRun,
}: {
  testRun: TestRun
}): JSX.Element => {
  return testRun.version == 2 ? (
    <TestsGroupList tests={testRun.tests} />
  ) : (
    <pre className="v1-output">
      <code dangerouslySetInnerHTML={{ __html: testRun.output }} />
    </pre>
  )
}
