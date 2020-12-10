import React, { useEffect, useCallback, useRef } from 'react'
import { TestRun, TestRunStatus } from './types'
import { TestRunChannel } from '../../channels/testRunChannel'
import { fetchJSON } from '../../utils/fetch-json'
import { TestsGroupList } from './TestsGroupList'

export const TestRunSummary = ({
  testRun,
  timeout,
  onUpdate,
  cancelLink,
}: {
  testRun: TestRun
  timeout: number
  onUpdate: (testRun: TestRun) => void
  cancelLink: string
}): JSX.Element => {
  const setTestRun = useCallback(
    (testRun) => {
      onUpdate(testRun)
    },
    [onUpdate]
  )
  const channel = useRef<TestRunChannel | undefined>()
  const timer = useRef<number | undefined>()
  const handleQueued = useCallback(() => {
    timer.current = window.setTimeout(() => {
      setTestRun({ ...testRun, status: TestRunStatus.TIMEOUT })
      timer.current = undefined
    }, timeout)
  }, [setTestRun, testRun, timeout])
  const handleTimeout = useCallback(() => {
    channel.current?.disconnect()
  }, [channel])
  const handleCancelling = useCallback(() => {
    clearTimeout(timer.current)

    fetchJSON(cancelLink, {
      method: 'POST',
    }).then(() => {
      setTestRun({ ...testRun, status: TestRunStatus.CANCELLED })
    })
  }, [cancelLink, setTestRun, testRun])
  const handleCancelled = useCallback(() => {
    clearTimeout(timer.current)

    channel.current?.disconnect()
  }, [channel, timer])
  const cancel = useCallback(() => {
    setTestRun({ ...testRun, status: TestRunStatus.CANCELLED })
  }, [setTestRun, testRun])

  useEffect(() => {
    switch (testRun.status) {
      case TestRunStatus.QUEUED:
        handleQueued()
        break
      case TestRunStatus.TIMEOUT:
        handleTimeout()
        break
      case TestRunStatus.CANCELLING:
        handleCancelling()
        break
      case TestRunStatus.CANCELLED:
        handleCancelled()
        break
      default:
        clearTimeout(timer.current)
        break
    }
  }, [
    testRun,
    handleQueued,
    handleTimeout,
    handleCancelling,
    handleCancelled,
    timer,
  ])

  useEffect(() => {
    channel.current = new TestRunChannel(testRun, (updatedTestRun: TestRun) => {
      setTestRun(updatedTestRun)
    })

    return () => {
      channel.current?.disconnect()
    }
  }, [setTestRun, testRun, testRun.submissionUuid])

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
    <>
      <TestRunSummary.Header testRun={testRun} />
      <TestRunSummary.Content testRun={testRun} onCancel={cancel} />
    </>
  )
}

TestRunSummary.Header = ({ testRun }: { testRun: TestRun }) => {
  switch (testRun.status) {
    case TestRunStatus.FAIL:
      return (
        <div className="summary-status failed">
          <span className="--dot" />1 test failure
        </div>
      )
    case TestRunStatus.PASS:
      return (
        <div className="summary-status passed">
          <span className="--dot" />
          All tests passed
        </div>
      )
    default:
      return null
  }
}

TestRunSummary.Content = ({
  testRun,
  onCancel,
}: {
  testRun: TestRun
  onCancel: () => void
}) => {
  switch (testRun.status) {
    case TestRunStatus.PASS:
    case TestRunStatus.FAIL:
      return <TestsGroupList tests={testRun.tests} />
    case TestRunStatus.ERROR:
      return (
        <div>
          <p>An error occurred</p>
          <p>We got the following error message when we ran your code:</p>
          <p>{testRun.message}</p>
        </div>
      )
    case TestRunStatus.OPS_ERROR:
      return (
        <div>
          <p>An error occurred</p>
          <p>{testRun.message}</p>
        </div>
      )
    case TestRunStatus.TIMEOUT:
      return (
        <div>
          <p>Tests timed out</p>
        </div>
      )
    case TestRunStatus.QUEUED:
      const handleCancel = useCallback(() => {
        onCancel()
      }, [onCancel])

      return (
        <div>
          <p>We've queued your code and will run it shortly.</p>
          <button type="button" onClick={handleCancel}>
            Cancel
          </button>
        </div>
      )
    default:
      return null
  }
}
