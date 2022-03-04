import React from 'react'
import { TestRun } from './types'
import { TestsGroupedByStatusList } from './TestsGroupedByStatusList'
import { TestsGroupedByTaskList } from './TestsGroupedByTaskList'

export const TestRunOutput = ({
  testRun,
}: {
  testRun: TestRun
}): JSX.Element => {
  const testsWithoutTasks = testRun.tests.filter(
    (t) => t.taskId == null || t.taskId == undefined
  )
  const hasTasks =
    testRun.version >= 3 &&
    testRun.tasks.length > 0 &&
    testsWithoutTasks.length == 0

  if (hasTasks) {
    return (
      <TestsGroupedByTaskList
        tests={testRun.tests}
        language={testRun.highlightjsLanguage}
        tasks={testRun.tasks}
      />
    )
  }

  if (testRun.version >= 2 && testRun.tests.length > 0) {
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
