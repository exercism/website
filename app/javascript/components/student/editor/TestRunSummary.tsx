import React, { useState, useEffect, useCallback, useRef } from 'react'
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
  const [testRun, setTestRun] = useState<TestRun>({
    submissionUuid: submission.uuid,
    status: submission.testsStatus,
    message: '',
    tests: [],
  })
  const channel = useRef<TestRunChannel | undefined>()
  const timer = useRef<number | undefined>()
  const handleQueued = useCallback(() => {
    timer.current = window.setTimeout(() => {
      setTestRun({ ...testRun, status: TestRunStatus.TIMEOUT })
      timer.current = undefined
    }, timeout)
  }, [timer])
  const handleTimeout = useCallback(() => {
    channel.current?.disconnect()
  }, [channel])

  useEffect(() => {
    switch (testRun.status) {
      case TestRunStatus.QUEUED:
        handleQueued()
        break
      case TestRunStatus.TIMEOUT:
        handleTimeout()
        break
      default:
        clearTimeout(timer.current)
        break
    }
  }, [testRun.status])

  useEffect(() => {
    channel.current = new TestRunChannel(submission, (testRun: TestRun) => {
      setTestRun(testRun)
    })

    return () => {
      channel.current?.disconnect()
    }
  }, [submission.uuid])

  useEffect(() => {
    return () => {
      channel.current?.disconnect()
    }
  }, [channel])

  useEffect(() => {
    return () => {
      clearTimeout(timer.current)
    }
  }, [timer])

  return (
    <div>
      <p>Status: {testRun.status}</p>
      <Content testRun={testRun} />
    </div>
  )
}
