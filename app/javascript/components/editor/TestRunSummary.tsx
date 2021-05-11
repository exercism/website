import React, { useEffect, useCallback, useRef } from 'react'
import { TestRun, TestRunStatus, TestStatus } from './types'
import { TestRunChannel } from '../../channels/testRunChannel'
import { fetchJSON } from '../../utils/fetch-json'
import { TestRunSummaryHeaderMessage } from './TestRunSummaryHeaderMessage'
import { TestRunFailures } from './TestRunFailures'
import { SubmitButton } from './SubmitButton'
import { GraphicalIcon, Loading } from '../common'
import { useRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'

const REFETCH_INTERVAL = 2000

export const TestRunSummary = ({
  testRun,
  timeout,
  onUpdate,
  onSubmit,
  isSubmitDisabled,
  cancelLink,
}: {
  testRun: TestRun
  timeout: number
  onUpdate: (testRun: TestRun) => void
  onSubmit: () => void
  isSubmitDisabled: boolean
  cancelLink: string
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
    <>
      <TestRunSummary.Header testRun={testRun} />
      <TestRunSummary.Content
        testRun={testRun}
        onSubmit={onSubmit}
        isSubmitDisabled={isSubmitDisabled}
        onCancel={cancel}
      />
    </>
  )
}

TestRunSummary.Header = ({ testRun }: { testRun: TestRun }) => {
  return <></>
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
  onSubmit,
  isSubmitDisabled,
  onCancel,
}: {
  testRun: TestRun
  onSubmit: () => void
  isSubmitDisabled: boolean
  onCancel: () => void
}) => {
  switch (testRun.status) {
    case TestRunStatus.PASS:
      return (
        <>
          {testRun.version == 2 ? <TestRunFailures testRun={testRun} /> : null}
          <div className="success-box">
            <GraphicalIcon icon="balloons" category="graphics" />
            <div className="content">
              <h3>Sweet. Looks like you’ve solved the exercise!</h3>
              <p>
                Good job! You can continue to improve your code or, if you're
                done, submit your solution to get automated feedback and request
                mentoring.
              </p>
              <SubmitButton onClick={onSubmit} disabled={isSubmitDisabled} />
            </div>
          </div>
        </>
      )
    case TestRunStatus.FAIL:
      return <TestRunFailures testRun={testRun} />
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
        <div className="ops-error">
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
        <div className="ops-error">
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

      /* TODO: Read this from db */
      const averageTestRunTime = 3

      return (
        <div role="status" className="running">
          <GraphicalIcon icon="spinner" />
          <div className="progress">
            <div
              className="bar"
              style={{ animationDuration: `${averageTestRunTime}s` }}
            />
          </div>
          <p>
            <strong>Running tests...</strong> Estimated running time ~
            {averageTestRunTime}s
          </p>
          <button
            type="button"
            onClick={handleCancel}
            className="btn-default btn-xs"
          >
            Cancel
          </button>
        </div>
      )
    default:
      return null
  }
}
