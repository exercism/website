import React from 'react'
import { TestRun } from './types'
import { TestsGroupList } from './TestsGroupList'

export const TestRunOutput = ({
  testRun,
}: {
  testRun: TestRun
}): JSX.Element => {
  return testRun.version === 2 || testRun.version === 3 ? (
    <TestsGroupList
      tests={testRun.tests}
      language={testRun.highlightjsLanguage}
    />
  ) : (
    <pre className="v1-message">
      <code>{testRun.messageHtml}</code>
    </pre>
  )
}
