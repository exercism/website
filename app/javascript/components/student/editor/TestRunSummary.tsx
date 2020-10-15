import React, { useState, useEffect } from 'react'
import { Submission, TestRunStatus } from '../Editor'
import consumer from '../../../utils/action-cable-consumer'

export type TestRun = {
  submissionUuid: string
  status: TestRunStatus
  message: string
  tests: Test[]
}

type Test = {
  name: string
  status: TestStatus
  output: string
}

enum TestStatus {
  PASS = 'pass',
  FAIL = 'fail',
}

export function TestRunSummary({ submission }: { submission: Submission }) {
  const [testRun, setTestRun] = useState<TestRun>({
    submissionUuid: submission.uuid,
    status: submission.testsStatus,
    message: '',
    tests: [],
  })

  useEffect(() => {
    const subscription = consumer.subscriptions.create(
      { channel: 'Test::Submission::TestRunsChannel', uuid: submission.uuid },
      {
        received: (json: any) => {
          setTestRun({
            submissionUuid: json.submission_uuid,
            status: json.status,
            message: json.message,
            tests: json.tests,
          })
        },
      }
    )

    return () => {
      subscription.unsubscribe()
    }
  }, [submission.uuid])

  let content
  switch (testRun.status) {
    case TestRunStatus.PASS:
    case TestRunStatus.FAIL:
      content = testRun.tests.map((test) => (
        <p key={test.name}>
          name: {test.name}, status: {test.status}, output: {test.output}
        </p>
      ))
      break
    case TestRunStatus.ERROR:
    case TestRunStatus.OPS_ERROR:
      content = <p>{testRun.message}</p>
      break
  }

  return (
    <div>
      <p>Status: {testRun.status}</p>
      {content}
    </div>
  )
}
