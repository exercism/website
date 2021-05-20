import React from 'react'
import { TestRun, TestRunStatus, TestStatus } from './types'
import { TestRunSummaryHeaderMessage } from './TestRunSummaryHeaderMessage'
import { TestRunFailures } from './TestRunFailures'
import { SubmitButton } from './SubmitButton'
import { GraphicalIcon } from '../common'

export const TestRunSummary = ({
  testRun,
  onSubmit,
  isSubmitDisabled,
  onCancel,
  averageTestDuration,
}: {
  testRun: TestRun
  onSubmit?: () => void
  isSubmitDisabled?: boolean
  onCancel?: () => void
  averageTestDuration?: number
}): JSX.Element =>
  testRun ? (
    <div className="c-test-run">
      <TestRunSummaryHeader testRun={testRun} />
      <TestRunSummaryContent
        testRun={testRun}
        onSubmit={onSubmit}
        isSubmitDisabled={isSubmitDisabled}
        onCancel={onCancel}
        averageTestDuration={averageTestDuration}
      />
    </div>
  ) : (
    <div className="automated-feedback-pending">
      <GraphicalIcon icon="spinner" />
      <h3>We&apos;re testing your code to check it works</h3>
      <p>This usually takes 5-20 seconds.</p>
    </div>
  )

const TestRunSummaryHeader = ({ testRun }: { testRun: TestRun }) => {
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

const TestRunSummaryContent = ({
  testRun,
  onSubmit,
  isSubmitDisabled,
  onCancel,
  averageTestDuration,
}: {
  testRun: TestRun
  onSubmit?: () => void
  isSubmitDisabled?: boolean
  onCancel?: () => void
  averageTestDuration?: number
}) => {
  switch (testRun.status) {
    case TestRunStatus.PASS: {
      return (
        <>
          {testRun.version === 2 || testRun.version === 3 ? (
            <TestRunFailures testRun={testRun} />
          ) : null}
          <div className="success-box">
            <GraphicalIcon icon="balloons" category="graphics" />
            <div className="content">
              <h3>Sweet. Looks like you’ve solved the exercise!</h3>
              <p>
                Good job! You can continue to improve your code or, if you're
                done, submit your solution to get automated feedback and request
                mentoring.
              </p>
              {onSubmit !== undefined && isSubmitDisabled !== undefined ? (
                <SubmitButton onClick={onSubmit} disabled={isSubmitDisabled} />
              ) : null}
            </div>
          </div>
        </>
      )
    }
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
