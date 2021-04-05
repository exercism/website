import React, { useEffect, useCallback, useRef } from 'react'
import { TestRun, TestRunStatus, TestStatus } from './types'
import { TestRunChannel } from '../../channels/testRunChannel'
import { fetchJSON } from '../../utils/fetch-json'
import { TestRunSummaryHeaderMessage } from './TestRunSummaryHeaderMessage'
import { TestRunTests } from './TestRunTests'

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
    case TestRunStatus.FAIL: {
      const failed = testRun.tests.filter(
        (test) =>
          test.status === TestStatus.FAIL || test.status === TestStatus.ERROR
      )

      return (
        <div className="summary-status failed" role="status">
          <span className="--dot" />
          <TestRunSummaryHeaderMessage
            version={testRun.version}
            numFailedTests={failed.length}
          />
        </div>
      )
    }
    case TestRunStatus.PASS:
      return (
        <div className="summary-status passed" role="status">
          <span className="--dot" />
          All tests passed
        </div>
      )
    case TestRunStatus.ERROR:
    case TestRunStatus.OPS_ERROR:
      return (
        <div className="summary-status errored" role="status">
          <span className="--dot" />
          An error occurred
        </div>
      )
    case TestRunStatus.TIMEOUT:
      return (
        <div className="summary-status errored" role="status">
          <span className="--dot" />
          Your tests timed out
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
      return <TestRunTests testRun={testRun} />
    case TestRunStatus.ERROR:
      return (
        <div className="error-message">
          <h3>We received the following error when we ran your code:</h3>
          <pre>
            <code dangerouslySetInnerHTML={{ __html: testRun.messageHtml }} />
          </pre>
        </div>
      )
    case TestRunStatus.OPS_ERROR:
      return (
        <div className="error-message">
          <p>
            An error occurred while running your tests. This might mean that
            there was an issue in our infrastructure, or it might mean that you
            have something in your code that's causing our systems to break.
          </p>
          <p>
            Please check your code, and if nothing seems to be wrong, try
            running the tests again.
          </p>
        </div>
      )
    case TestRunStatus.TIMEOUT:
      return (
        <div className="error-message">
          <p>
            Your tests timed out. This might mean that there was an issue in our
            infrastructure, or it might mean that you have some infinite loop in
            your code.
          </p>
          <p>
            Please check your code, and if nothing seems to be wrong, try
            running the tests again.
          </p>
        </div>
      )
    case TestRunStatus.QUEUED:
      const handleCancel = useCallback(() => {
        onCancel()
      }, [onCancel])

      return (
        <div role="status">
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
