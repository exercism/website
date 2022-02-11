import React from 'react'
import { TestRun, TestRunnerStatus, TestRunStatus, TestStatus } from './types'
import { TestRunSummaryByStatusHeaderMessage } from './TestRunSummaryByStatusHeaderMessage'
import { TestRunOutput } from './TestRunOutput'
import { SubmitButton } from './SubmitButton'
import { GraphicalIcon } from '../common'

export const TestRunSummary = ({
  testRun,
  testRunnerStatus,
  onSubmit,
  isSubmitDisabled,
  onCancel,
  averageTestDuration,
  showSuccessBox,
}: {
  testRun: TestRun
  testRunnerStatus?: TestRunnerStatus
  onSubmit?: () => void
  isSubmitDisabled?: boolean
  onCancel?: () => void
  averageTestDuration?: number
  showSuccessBox: boolean
}): JSX.Element => {
  if (testRun) {
    return (
      <div className="c-test-run">
        <TestRunSummaryHeader testRun={testRun} />
        <TestRunSummaryContent
          testRun={testRun}
          onSubmit={onSubmit}
          isSubmitDisabled={isSubmitDisabled}
          onCancel={onCancel}
          averageTestDuration={averageTestDuration}
          showSuccessBox={showSuccessBox}
        />
      </div>
    )
  }

  if (testRunnerStatus && !testRunnerStatus.track) {
    return (
      <div className="test-runner-disabled">
        <h3>No test results</h3>
        <p>This track does not support automatically running exercise tests.</p>
      </div>
    )
  }

  if (testRunnerStatus && !testRunnerStatus.exercise) {
    return (
      <div className="test-runner-disabled">
        <h3>No test results</h3>
        <p>This exercise does not support automatically running its tests.</p>
      </div>
    )
  }

  return (
    <div className="automated-feedback-pending">
      <GraphicalIcon icon="spinner" />
      <h3>We&apos;re testing your code to check it works</h3>
      <p>This usually takes 5-20 seconds.</p>
    </div>
  )
}

const TestRunSummaryStatus = ({
  statusClass,
  children,
}: React.PropsWithChildren<{ statusClass: string }>): JSX.Element => {
  return (
    <div className={`summary-status ${statusClass}`} role="status">
      <span className="--dot" />
      {children}
    </div>
  )
}

const TestRunSummaryHeader = ({ testRun }: { testRun: TestRun }) => {
  switch (testRun.status) {
    case TestRunStatus.FAIL: {
      const failed = testRun.tests.filter(
        (test) =>
          test.status === TestStatus.FAIL || test.status === TestStatus.ERROR
      )

      if (testRun.tasks && testRun.tasks.length > 0) {
        const numFailedTasks = new Set(
          failed
            .filter((test) => test.taskId !== undefined)
            .map((test) => test.taskId)
        ).size
        // TODO: render background as percentage
        return (
          <TestRunSummaryStatus statusClass="failed">
            {testRun.tasks.length - numFailedTasks} / {testRun.tasks.length}{' '}
            tasks completed
          </TestRunSummaryStatus>
        )
      }

      return (
        <TestRunSummaryStatus statusClass="failed">
          <TestRunSummaryByStatusHeaderMessage
            version={testRun.version}
            numFailedTests={failed.length}
          />
        </TestRunSummaryStatus>
      )
    }
    case TestRunStatus.PASS:
      if (testRun.tasks && testRun.tasks.length > 0) {
        return (
          <TestRunSummaryStatus statusClass="passed">
            All tasks passed
          </TestRunSummaryStatus>
        )
      }

      return (
        <TestRunSummaryStatus statusClass="passed">
          All tests passed
        </TestRunSummaryStatus>
      )
    case TestRunStatus.ERROR:
    case TestRunStatus.OPS_ERROR:
      return (
        <TestRunSummaryStatus statusClass="errored">
          An error occurred
        </TestRunSummaryStatus>
      )
    case TestRunStatus.TIMEOUT:
      return (
        <TestRunSummaryStatus statusClass="errored">
          Your tests timed out
        </TestRunSummaryStatus>
      )
    default:
      return null
  }
}

const TestRunSummaryContent = ({
  testRun,
  onSubmit,
  isSubmitDisabled,
  onCancel,
  averageTestDuration,
  showSuccessBox,
}: {
  testRun: TestRun
  onSubmit?: () => void
  isSubmitDisabled?: boolean
  onCancel?: () => void
  averageTestDuration?: number
  showSuccessBox: boolean
}) => {
  switch (testRun.status) {
    case TestRunStatus.PASS: {
      return (
        <>
          {testRun.version === 2 || testRun.version === 3 ? (
            <TestRunOutput testRun={testRun} />
          ) : null}
          {showSuccessBox ? (
            <div className="success-box">
              <GraphicalIcon icon="balloons" category="graphics" />
              <div className="content">
                <h3>Sweet. Looks like you’ve solved the exercise!</h3>
                <p>
                  Good job! You can continue to improve your code or, if you're
                  done, submit an iteration to get automated feedback and
                  optionally request mentoring.
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
          <GraphicalIcon icon="spinner" />
          <div className="progress">
            {averageTestDuration ? (
              <div
                className="bar"
                style={{ animationDuration: `${averageTestDuration}s` }}
              />
            ) : null}
          </div>
          <p>
            <strong>Running tests...</strong>
            {averageTestDuration !== undefined ? (
              <span>Estimated running time ~ {averageTestDuration}s</span>
            ) : null}
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
