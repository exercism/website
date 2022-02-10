import React from 'react'
import { TestRun } from './types'
import { TestsGroupedByStatusList } from './TestsGroupedByStatusList'

export const TestRunOutput = ({
  testRun,
}: {
  testRun: TestRun
}): JSX.Element => {
  return testRun.version === 2 || testRun.version === 3 ? (
    <TestsGroupedByStatusList
      tests={testRun.tests}
      language={testRun.highlightjsLanguage}
    />
  ) : (
    <pre className="v1-message">
      <code dangerouslySetInnerHTML={{ __html: testRun.messageHtml }} />
    </pre>
  )
}
