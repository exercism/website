import React, { useState, useEffect, useRef } from 'react'
import { Submission, TestRunStatus, Action } from '../Editor'
import { TestRunChannel } from '../../../channels/testRunChannel'
import { fetchJSON } from '../../../utils/fetch-json'

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
  const timer = useRef<number>()
  const channel = useRef<TestRunChannel>()

  useEffect(() => {
    channel.current = new TestRunChannel(submission, (testRun: TestRun) => {
      setTestRun(testRun)
    })

    return () => {
      if (channel.current) {
        channel.current.disconnect()
      }
    }
  }, [submission.uuid])

  useEffect(() => {
    switch (testRun.status) {
      case TestRunStatus.QUEUED:
        timer.current = window.setTimeout(
          () => setTestRun({ ...testRun, status: TestRunStatus.TIMEOUT }),
          timeout
        )

        break
      case TestRunStatus.CANCELLING:
        fetchJSON(submission.links.cancel, {
          method: 'POST',
        }).then(() => {
          setTestRun({ ...testRun, status: TestRunStatus.CANCELLED })
        })

        break
      case TestRunStatus.CANCELLED:
        if (channel.current) {
          channel.current.disconnect()
        }

        break
    }
  }, [testRun.status])

  useEffect(() => {
    return () => {
      clearTimeout(timer.current)
    }
  }, [])

  return (
    <div>
      <p>Status: {testRun.status}</p>
      {status === TestRunStatus.QUEUED && (
        <button
          onClick={() => {
            setTestRun({ ...testRun, status: TestRunStatus.CANCELLED })
          }}
        >
          Cancel
        </button>
      )}
      <Content testRun={testRun} />
    </div>
  )
}
