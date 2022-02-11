import React from 'react'
import { AssignmentTask, TestRun } from './types'
import { TestsGroupedByStatusList } from './TestsGroupedByStatusList'
import { TestsGroupedByTaskList } from './TestsGroupedByTaskList'

export const TestRunOutput = ({
  testRun,
  tasks,
}: {
  testRun: TestRun
  tasks: AssignmentTask[]
}): JSX.Element => {
  if (testRun.version === 3) {
    return (
      <TestsGroupedByTaskList
        tests={testRun.tests}
        language={testRun.highlightjsLanguage}
        tasks={tasks}
      />
    )
  }

  if (testRun.version === 2) {
    return (
      <TestsGroupedByStatusList
        tests={testRun.tests}
        language={testRun.highlightjsLanguage}
      />
    )
  }

  return (
    <pre className="v1-message">
      <code dangerouslySetInnerHTML={{ __html: testRun.messageHtml }} />
    </pre>
  )
}
