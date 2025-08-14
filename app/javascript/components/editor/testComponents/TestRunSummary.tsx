// i18n-key-prefix: testRunSummary
// i18n-namespace: components/editor/testComponents
import React from 'react'
import { TestRun, TestRunner, TestRunStatus, TestStatus } from '../types'
import { TestRunSummaryByStatusHeaderMessage } from './TestRunSummaryByStatusHeaderMessage'
import { TestRunOutput } from './TestRunOutput'
import { SubmitButton } from '../SubmitButton'
import { GraphicalIcon } from '../../common'
import { LoadingBar } from '../../common/LoadingBar'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  const { t } = useAppTranslation('components/editor/testComponents')

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
        <h3>{t('testRunSummary.noTestResults')}</h3>
        <p>{t('testRunSummary.trackNotSupportTests')}</p>
      </div>
    )
  }

  if (testRunner.status && !testRunner.status.exercise) {
    return (
      <div className="test-runner-disabled">
        <h3>{t('testRunSummary.noTestResults')}</h3>
        <p>{t('testRunSummary.exerciseNotSupportTests')}</p>
      </div>
    )
  }

  return (
    <div className="automated-feedback-pending">
      <GraphicalIcon
        icon="spinner"
        className="animate-spin-slow filter-textColor6"
      />
      <h3>{t('testRunSummary.testingCode')}</h3>
      <p>
        {t('testRunSummary.usuallyTakes', {
          averageTestDuration: testRunner.averageTestDuration,
          averageTestDurationMultiplied: testRunner.averageTestDuration * 4,
        })}
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
  const { t } = useAppTranslation('components/editor/testComponents')

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
            {t('testRunSummary.tasksCompleted', {
              completedTasks: testRun.tasks.length - numFailedTasks,
              totalTasks: testRun.tasks.length,
            })}
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
            {t('testRunSummary.allTasksPassed')}
          </TestRunSummaryStatus>
        )
      }

      return (
        <TestRunSummaryStatus statusClass="passed" percentagePassing={100}>
          {t('testRunSummary.allTestsPassed')}
        </TestRunSummaryStatus>
      )
    case TestRunStatus.ERROR:
    case TestRunStatus.OPS_ERROR:
      return (
        <TestRunSummaryStatus statusClass="errored" percentagePassing={100}>
          {t('testRunSummary.anErrorOccurred')}
        </TestRunSummaryStatus>
      )
    case TestRunStatus.TIMEOUT:
      return (
        <TestRunSummaryStatus statusClass="errored" percentagePassing={100}>
          {t('testRunSummary.yourTestsTimedOut')}
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
  const { t } = useAppTranslation('components/editor/testComponents')

  switch (testRun.status) {
    case TestRunStatus.PASS: {
      return (
        <>
          {showSuccessBox ? (
            <div className="success-box">
              <GraphicalIcon icon="balloons" category="graphics" />
              <div className="content">
                <h3>{t('testRunSummary.sweetLooksLike')}</h3>
                <p>{t('testRunSummary.goodJobContinueImprove')}</p>
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
          <h3>{t('testRunSummary.weReceivedError')}</h3>
          <pre>
            <code dangerouslySetInnerHTML={{ __html: testRun.messageHtml }} />
          </pre>
        </div>
      )
    case TestRunStatus.OPS_ERROR:
      return (
        <div className="ops-error">
          <p>{t('testRunSummary.errorOccurredWhileRunningTests')}</p>
          <p>{t('testRunSummary.pleaseCheckCode')}</p>
        </div>
      )
    case TestRunStatus.TIMEOUT:
      return (
        <div className="ops-error">
          <p>
            {t('testRunSummary.yourTestsTimedOutSuggestsCodeRunningSlowly')}
          </p>
          <p>{t('testRunSummary.pleaseCheckCode')}</p>
        </div>
      )
    case TestRunStatus.QUEUED: {
      return (
        <div role="status" className="running">
          <GraphicalIcon
            icon="spinner"
            className="animate-spin-slow filter-textColor6"
          />
          <LoadingBar animationDuration={testRunner.averageTestDuration} />
          <p>
            <strong>{t('testRunSummary.runningTests')}</strong>&nbsp;
            <span>
              {t('testRunSummary.estimatedRunningTime', {
                averageTestDuration: testRunner.averageTestDuration,
              })}
            </span>
          </p>
          {onCancel !== undefined &&
          testRun.submissionUuid !== 'faux-submission' ? (
            <button
              type="button"
              onClick={() => onCancel()}
              className="btn-default btn-xs"
            >
              {t('testRunSummary.cancel')}
            </button>
          ) : null}
        </div>
      )
    }
    default:
      return null
  }
}
