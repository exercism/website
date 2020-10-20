import React, { useReducer, useEffect } from 'react'
import { Submission, TestRunStatus } from '../Editor'
import { TestRunChannel } from '../../../channels/testRunChannel'

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

function reducer(state: any, action: any) {
  switch (action.type) {
    case 'testRun.received':
      return action.payload
    case 'testRun.timeout':
      return { ...state, status: 'timeout' }
  }
}

function Content({ testRun }: { testRun: TestRun }) {
  switch (testRun.status) {
    case TestRunStatus.PASS:
    case TestRunStatus.FAIL:
      return (
        <>
          {testRun.tests.map((test: Test) => (
            <p key={test.name}>
              name: {test.name}, status: {test.status}, output: {test.output}
            </p>
          ))}
        </>
      )
    case TestRunStatus.ERROR:
    case TestRunStatus.OPS_ERROR:
      return <p>{testRun.message}</p>
    default:
      return <></>
  }
}

export function TestRunSummary({
  submission,
  timeout,
}: {
  submission: Submission
  timeout: number
}) {
  const RESOLVED_TEST_STATUSES = [
    TestRunStatus.PASS,
    TestRunStatus.FAIL,
    TestRunStatus.ERROR,
    TestRunStatus.OPS_ERROR,
  ]
  const [testRun, dispatch] = useReducer(reducer, {
    submissionUuid: submission.uuid,
    status: submission.testsStatus,
    message: '',
    tests: [],
  })
  const haveTestsResolved = RESOLVED_TEST_STATUSES.includes(testRun.status)

  useEffect(() => {
    const channel = new TestRunChannel(submission, (testRun: TestRun) => {
      dispatch({ type: 'testRun.received', payload: testRun })
    })

    return () => {
      channel.disconnect()
    }
  }, [submission.uuid])

  useEffect(() => {
    if (haveTestsResolved) {
      return
    }

    setTimeout(() => dispatch({ type: 'testRun.timeout' }), timeout)
  }, [testRun.status])

  return (
    <div>
      <p>Status: {testRun.status}</p>
      <Content testRun={testRun} />
    </div>
  )
}
