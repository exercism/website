import React, { useEffect, useCallback, useRef } from 'react'
import { TestRun, TestRunStatus } from './types'
import { TestRunChannel } from '../../channels/testRunChannel'
import { TestRunSummaryContent } from './TestRunSummaryContent'
import { fetchJSON } from '../../utils/fetch-json'

const TestRunSummaryHeader = ({ testRun }: { testRun: TestRun }) => {
  switch (testRun.status) {
    case TestRunStatus.FAIL:
      return (
        <div className="summary-status failed">
          <span className="--dot" />1 test failure
        </div>
      )
    case TestRunStatus.PASS:
      return (
        <div className="summary-status">
          <span className="--dot" />
          All tests passed
        </div>
      )
    default:
      return null
  }
}

export function TestRunSummary({
  testRun,
  timeout,
  onUpdate,
  cancelLink,
}: {
  testRun: TestRun
  timeout: number
  onUpdate: (testRun: TestRun) => void
  cancelLink: string
}): JSX.Element {
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
      <TestRunSummaryHeader testRun={testRun} />
      <TestRunSummaryContent testRun={testRun} onCancel={cancel} />
    </>
  )
}
