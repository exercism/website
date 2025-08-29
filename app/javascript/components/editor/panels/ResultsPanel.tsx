import React from 'react'
import { TestRunSummaryContainer } from '../testComponents/TestRunSummaryContainer'
import { Submission, TestRun, TestRunner } from '../types'
import { GraphicalIcon, Tab } from '../../common'
import { TabsContext } from '../../Editor'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export const ResultsPanel = ({
  submission,
  timeout,
  onUpdate,
  onRunTests,
  onSubmit,
  isSubmitDisabled,
  testRunner,
  hasCancelled,
}: {
  submission: Submission | null
  timeout: number
  onUpdate: (testRun: TestRun) => void
  onSubmit: () => void
  onRunTests: () => void
  isSubmitDisabled: boolean
  testRunner: TestRunner
  hasCancelled: boolean
}): JSX.Element => {
  const { t } = useAppTranslation('components/editor/panels')
  return (
    <Tab.Panel id="results" context={TabsContext}>
      {hasCancelled ? (
        <div className="c-toast cancelled">
          <GraphicalIcon icon="completed-check-circle" />
          <span>{t('resultsPanel.testRunCancelled')}</span>
        </div>
      ) : null}
      {submission && submission.testRun ? (
        <section className="results">
          <TestRunSummaryContainer
            testRun={submission.testRun}
            testRunner={testRunner}
            cancelLink={submission.links.cancel}
            timeout={timeout}
            onUpdate={onUpdate}
            onSubmit={onSubmit}
            isSubmitDisabled={isSubmitDisabled}
          />
        </section>
      ) : (
        <section className="run-tests-prompt">
          <GraphicalIcon icon="run-tests-prompt" />
          <h2>
            <Trans
              ns="components/editor/panels"
              i18nKey="resultsPanel.runTestsToCheckYourCode"
              components={[
                <button
                  className="btn-keyboard-shortcut"
                  type="button"
                  onClick={onRunTests}
                />,
              ]}
            />
          </h2>
          <p>{t('resultsPanel.wellRunYourCode')}</p>
        </section>
      )}
    </Tab.Panel>
  )
}
