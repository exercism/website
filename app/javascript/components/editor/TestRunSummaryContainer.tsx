import React, { useEffect, useCallback, useRef } from 'react'
import { TestRun, TestRunner, TestRunStatus } from './types'
import { TestRunChannel } from '../../channels/testRunChannel'
import { fetchJSON } from '../../utils/fetch-json'
import { useRequestQuery } from '../../hooks/request-query'
import { TestRunSummary } from './TestRunSummary'

const REFETCH_INTERVAL = 2000

export const TestRunSummaryContainer = ({
  testRun,
  testRunner,
  timeout,
  onUpdate,
  onSubmit,
  isSubmitDisabled,
  cancelLink,
}: {
  testRun: TestRun
  testRunner: TestRunner
  timeout: number
  onUpdate: (testRun: TestRun) => void
  onSubmit: () => void
  isSubmitDisabled: boolean
  cancelLink: string
}): JSX.Element | null => {
  const { data } = useRequestQuery<{ testRun: TestRun }>(
    [`test-run-${testRun.submissionUuid}`],
    {
      endpoint: testRun.links.self,
      options: {
        refetchInterval:
          testRun.status === TestRunStatus.QUEUED ? REFETCH_INTERVAL : false,
      },
    }
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
    clearTimeout(timer.current)

    timer.current = window.setTimeout(() => {
      setTestRun({ ...testRun, status: TestRunStatus.TIMEOUT })
      timer.current = undefined
    }, timeout)
  }, [setTestRun, JSON.stringify(testRun), timeout])

  const cancel = useCallback(() => {
    setTestRun({ ...testRun, status: TestRunStatus.CANCELLED })

    fetchJSON(cancelLink, { method: 'PATCH' })
  }, [cancelLink, setTestRun, JSON.stringify(testRun)])

  useEffect(() => {
    if (!data || !data.testRun) {
      return
    }

    setTestRun(data.testRun)
  }, [JSON.stringify(data), setTestRun])

  useEffect(() => {
    switch (testRun.status) {
      case TestRunStatus.QUEUED:
        handleQueued()
        break
      default:
        clearTimeout(timer.current)
        channel.current?.disconnect()
        break
    }
  }, [handleQueued, testRun.status])

  useEffect(() => {
    channel.current = new TestRunChannel(testRun, (updatedTestRun: TestRun) => {
      if (testRun.status !== TestRunStatus.QUEUED) {
        return
      }

      setTestRun(updatedTestRun)
    })

    return () => channel.current?.disconnect()
  }, [setTestRun, JSON.stringify(testRun)])

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
      testRunner={testRunner}
      onSubmit={onSubmit}
      isSubmitDisabled={isSubmitDisabled}
      onCancel={cancel}
      showSuccessBox={true}
    />
  )
}
