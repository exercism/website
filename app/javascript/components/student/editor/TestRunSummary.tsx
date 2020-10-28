import React, { useState, useEffect, useCallback, useRef } from 'react'
import { Submission, TestRun, TestRunStatus } from '../Editor'
import { TestRunChannel } from '../../../channels/testRunChannel'
import { TestRunSummaryContent } from './TestRunSummaryContent'
import { fetchJSON } from '../../../utils/fetch-json'

export function TestRunSummary({
  submission,
  timeout,
  onUpdate,
}: {
  submission: Submission
  timeout: number
  onUpdate: (submission: Submission) => void
}) {
  const setTestRun = useCallback(
    (testRun) => {
      onUpdate({
        uuid: submission.uuid,
        testsStatus: testRun.status,
        testRun: testRun,
        links: submission.links,
      })
    },
    [onUpdate]
  )
  const channel = useRef<TestRunChannel | undefined>()
  const timer = useRef<number | undefined>()
  const handleQueued = useCallback(() => {
    timer.current = window.setTimeout(() => {
      setTestRun({ ...submission.testRun, status: TestRunStatus.TIMEOUT })
      timer.current = undefined
    }, timeout)
  }, [timer])
  const handleTimeout = useCallback(() => {
    channel.current?.disconnect()
  }, [channel])
  const handleCancelling = useCallback(() => {
    clearTimeout(timer.current)

    fetchJSON(submission.links.cancel, {
      method: 'POST',
    }).then(() => {
      setTestRun({ ...submission.testRun, status: TestRunStatus.CANCELLED })
    })
  }, [timer])
  const handleCancelled = useCallback(() => {
    clearTimeout(timer.current)

    channel.current?.disconnect()
  }, [channel, timer])
  const cancel = useCallback(() => {
    setTestRun({ ...submission.testRun, status: TestRunStatus.CANCELLED })
  }, [])

  useEffect(() => {
    switch (submission.testsStatus) {
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
    submission.testsStatus,
    handleQueued,
    handleTimeout,
    handleCancelling,
    handleCancelled,
    timer,
  ])

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
      <p>Status: {submission.testsStatus}</p>
      <TestRunSummaryContent submission={submission} onCancel={cancel} />
    </div>
  )
}
