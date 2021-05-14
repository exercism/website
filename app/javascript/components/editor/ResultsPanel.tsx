import React from 'react'
import { TestRunSummary } from './TestRunSummary'
import { Submission, TestRun } from './types'
import { GraphicalIcon, Tab } from '../common'
import { TabsContext } from '../Editor'

export const ResultsPanel = ({
  submission,
  timeout,
  onUpdate,
  onSubmit,
  isSubmitDisabled,
  averageTestRunTime,
}: {
  submission: Submission | undefined
  timeout: number
  onUpdate: (testRun: TestRun) => void
  onSubmit: () => void
  isSubmitDisabled: boolean
  averageTestRunTime: number
}) => (
  <Tab.Panel id="results" context={TabsContext}>
    {submission && submission.testRun ? (
      <section className="results">
        <TestRunSummary
          testRun={submission.testRun}
          cancelLink={submission.links.cancel}
          timeout={timeout}
          onUpdate={onUpdate}
          onSubmit={onSubmit}
          isSubmitDisabled={isSubmitDisabled}
          averageTestRunTime={averageTestRunTime}
        />
      </section>
    ) : (
      <section className="run-tests-prompt">
        <GraphicalIcon icon="run-tests-prompt" />
        <h2>
          <button className="btn-keyboard-shortcut">
            <span>Run tests </span>
            <span className="--kb">F2</span>
          </button>{' '}
          to check your code
        </h2>
        <p>
          We'll run your code against tests to check whether it works, then give
          you the results here.
        </p>
      </section>
    )}
  </Tab.Panel>
)
