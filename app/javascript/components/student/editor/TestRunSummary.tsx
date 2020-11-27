import React, { useState, useEffect, useCallback, useRef } from 'react'
import { Submission, TestRun, TestRunStatus } from './types'
import { TestRunChannel } from '../../../channels/testRunChannel'
import { TestRunSummaryContent } from './TestRunSummaryContent'
import { fetchJSON } from '../../../utils/fetch-json'

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
}) {
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
  }, [timer])
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
  }, [timer])
  const handleCancelled = useCallback(() => {
    clearTimeout(timer.current)

    channel.current?.disconnect()
  }, [channel, timer])
  const cancel = useCallback(() => {
    setTestRun({ ...testRun, status: TestRunStatus.CANCELLED })
  }, [])

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
  }, [testRun.submissionUuid])

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
      <TestRunSummaryContent testRun={testRun} onCancel={cancel} />
    </div>
  )
}
