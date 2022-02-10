import React from 'react'
import { AssignmentTask, TestRun } from './types'
import { TestsGroupedByStatusList } from './TestsGroupedByStatusList'

export const TestRunOutput = ({
  testRun,
  tasks,
}: {
  testRun: TestRun
  tasks: AssignmentTask[]
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
