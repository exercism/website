import React from 'react'
import { TestRun, TestRunner, TestRunStatus, TestStatus } from './types'
import { TestRunSummaryByStatusHeaderMessage } from './TestRunSummaryByStatusHeaderMessage'
import { TestRunOutput } from './TestRunOutput'
import { SubmitButton } from './SubmitButton'
import { GraphicalIcon } from '../common'
import { LoadingBar } from '../common/LoadingBar'

export const TestRunSummary = ({
  testRun,
  testRunner,
  onSubmit,
  isSubmitDisabled,
  onCancel,
  showSuccessBox,
}: {
  testRun: TestRun
  testRunner: TestRunner
  onSubmit?: () => void
  isSubmitDisabled?: boolean
  onCancel?: () => void
  showSuccessBox: boolean
}): JSX.Element => {
  if (testRun) {
    return (
      <div className="c-test-run">
        <TestRunSummaryHeader testRun={testRun} />
        <TestRunSummaryContent
          testRun={testRun}
          testRunner={testRunner}
          onSubmit={onSubmit}
          isSubmitDisabled={isSubmitDisabled}
          onCancel={onCancel}
          showSuccessBox={showSuccessBox}
        />
      </div>
    )
  }

  if (testRunner.status && !testRunner.status.track) {
    return (
      <div className="test-runner-disabled">
        <h3>No test results</h3>
        <p>This track does not support automatically running exercise tests.</p>
      </div>
    )
  }

  if (testRunner.status && !testRunner.status.exercise) {
    return (
      <div className="test-runner-disabled">
        <h3>No test results</h3>
        <p>This exercise does not support automatically running its tests.</p>
      </div>
    )
  }

  return (
    <div className="automated-feedback-pending">
      <GraphicalIcon icon="spinner" className="animate-spin-slow" />
      <h3>We&apos;re testing your code to check it works</h3>
      <p>
        This usually takes {testRunner.averageTestDuration}-
        {testRunner.averageTestDuration * 4} seconds.
      </p>
    </div>
  )
}

const TestRunSummaryStatus = ({
  statusClass,
  children,
  percentagePassing,
}: React.PropsWithChildren<{
  statusClass: string
  percentagePassing: number
}>): JSX.Element => {
  return (
    <>
      <div className={`progress ${statusClass}`}>
        <div className="bar" style={{ width: `${percentagePassing}%` }} />
      </div>
      <div className={`summary-status ${statusClass}`} role="status">
        <span className="--dot" />
        {children}
      </div>
    </>
  )
}

const TestRunSummaryHeader = ({ testRun }: { testRun: TestRun }) => {
  const hasTasks =
    testRun.version >= 3 &&
    testRun.tasks.length > 0 &&
    testRun.tests.every((t) => t.taskId !== null && t.taskId !== undefined)

  switch (testRun.status) {
    case TestRunStatus.FAIL: {
      const failed = testRun.tests.filter(
        (test) =>
          test.status === TestStatus.FAIL || test.status === TestStatus.ERROR
      )

      if (hasTasks) {
        const numFailedTasks = new Set(
          failed
            .filter((test) => test.taskId !== undefined)
            .map((test) => test.taskId)
        ).size

        return (
          <TestRunSummaryStatus
            statusClass="failed grouped-by-task"
            percentagePassing={
              ((testRun.tests.length - failed.length) / testRun.tests.length) *
              100
            }
          >
            {testRun.tasks.length - numFailedTasks} / {testRun.tasks.length}{' '}
            Tasks Completed
          </TestRunSummaryStatus>
        )
      }

      return (
        <TestRunSummaryStatus
          statusClass="failed"
          percentagePassing={
            ((testRun.tests.length - failed.length) / testRun.tests.length) *
            100
          }
        >
          <TestRunSummaryByStatusHeaderMessage
            version={testRun.version}
            numFailedTests={failed.length}
          />
        </TestRunSummaryStatus>
      )
    }
    case TestRunStatus.PASS:
      if (hasTasks) {
        return (
          <TestRunSummaryStatus statusClass="passed" percentagePassing={100}>
            All tasks passed
          </TestRunSummaryStatus>
        )
      }

      return (
        <TestRunSummaryStatus statusClass="passed" percentagePassing={100}>
          All tests passed
        </TestRunSummaryStatus>
      )
    case TestRunStatus.ERROR:
    case TestRunStatus.OPS_ERROR:
      return (
        <TestRunSummaryStatus statusClass="errored" percentagePassing={100}>
          An error occurred
        </TestRunSummaryStatus>
      )
    case TestRunStatus.TIMEOUT:
      return (
        <TestRunSummaryStatus statusClass="errored" percentagePassing={100}>
          Your tests timed out
        </TestRunSummaryStatus>
      )
    default:
      return null
  }
}

const TestRunSummaryContent = ({
  testRun,
  testRunner,
  onSubmit,
  isSubmitDisabled,
  onCancel,
  showSuccessBox,
}: {
  testRun: TestRun
  testRunner: TestRunner
  onSubmit?: () => void
  isSubmitDisabled?: boolean
  onCancel?: () => void
  showSuccessBox: boolean
}) => {
  switch (testRun.status) {
    case TestRunStatus.PASS: {
      return (
        <>
          {showSuccessBox ? (
            <div className="success-box">
              <GraphicalIcon icon="balloons" category="graphics" />
              <div className="content">
                <h3>Sweet. Looks like you&apos;ve solved the exercise!</h3>
                <p>
                  Good job! You can continue to improve your code or, if
                  you&apos;re done, submit an iteration to get automated
                  feedback and optionally request mentoring.
                </p>
                {onSubmit !== undefined && isSubmitDisabled !== undefined ? (
                  <SubmitButton
                    onClick={onSubmit}
                    disabled={isSubmitDisabled}
                  />
                ) : null}
              </div>
            </div>
          ) : null}
          {testRun.version === 2 || testRun.version === 3 ? (
            <TestRunOutput testRun={testRun} />
          ) : null}
        </>
      )
    }
    case TestRunStatus.FAIL:
      return <TestRunOutput testRun={testRun} />
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
            have something in your code that&apos;s causing our systems to
            break.
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
            infrastructure, but more likely it suggests that your code is
            running slowly. Is there an infinite loop or something similar?
          </p>
          <p>
            Please check your code, and if nothing seems to be wrong, try
            running the tests again.
          </p>
        </div>
      )
    case TestRunStatus.QUEUED: {
      return (
        <div role="status" className="running">
          <GraphicalIcon icon="spinner" className="animate-spin-slow" />
          <LoadingBar animationDuration={testRunner.averageTestDuration} />
          <p>
            <strong>Running tests…</strong>&nbsp;
            <span>
              Estimated running time ~ {testRunner.averageTestDuration}s
            </span>
          </p>
          {onCancel !== undefined ? (
            <button
              type="button"
              onClick={() => onCancel()}
              className="btn-default btn-xs"
            >
              Cancel
            </button>
          ) : null}
        </div>
      )
    }
    default:
      return null
  }
}
