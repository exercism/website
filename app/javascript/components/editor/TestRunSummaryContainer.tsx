import React, { useEffect, useCallback, useRef } from 'react'
import { TestRun, TestRunStatus } from './types'
import { TestRunChannel } from '../../channels/testRunChannel'
import { fetchJSON } from '../../utils/fetch-json'
import { useRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { TestRunSummary } from './TestRunSummary'

const REFETCH_INTERVAL = 2000

export const TestRunSummaryContainer = ({
  testRun,
  timeout,
  onUpdate,
  onSubmit,
  isSubmitDisabled,
  cancelLink,
  averageTestDuration,
}: {
  testRun: TestRun
  timeout: number
  onUpdate: (testRun: TestRun) => void
  onSubmit: () => void
  isSubmitDisabled: boolean
  cancelLink: string
  averageTestDuration: number
}): JSX.Element | null => {
  const isMountedRef = useIsMounted()
  const { data } = useRequestQuery<{ testRun: TestRun }>(
    `test-run-${testRun.submissionUuid}`,
    {
      endpoint: testRun.links.self,
      options: {
        initialData: { testRun: testRun },
        refetchInterval:
          testRun.status === TestRunStatus.QUEUED ? REFETCH_INTERVAL : false,
      },
    },
    isMountedRef
  )
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
  }, [cancelLink, testRun, setTestRun])
  const handleCancelled = useCallback(() => {
    clearTimeout(timer.current)

    channel.current?.disconnect()
  }, [channel, timer])
  const cancel = useCallback(() => {
    setTestRun({ ...testRun, status: TestRunStatus.CANCELLED })
  }, [testRun, setTestRun])

  useEffect(() => {
    if (!data) {
      return
    }

    if (!data.testRun) {
      return
    }

    setTestRun(data.testRun)
  }, [data, setTestRun])

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
    handleQueued,
    handleTimeout,
    handleCancelling,
    handleCancelled,
    timer,
    testRun.status,
  ])

  useEffect(() => {
    channel.current = new TestRunChannel(testRun, (updatedTestRun: TestRun) => {
      setTestRun(updatedTestRun)
    })

    return () => {
      channel.current?.disconnect()
    }
  }, [setTestRun, testRun])

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
    <TestRunSummary
      testRun={testRun}
      onSubmit={onSubmit}
      isSubmitDisabled={isSubmitDisabled}
      onCancel={cancel}
      averageTestDuration={averageTestDuration}
      showSuccessBox={true}
    />
  )
}
