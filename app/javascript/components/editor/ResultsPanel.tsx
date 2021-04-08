import React from 'react'
import { TestRunSummary } from './TestRunSummary'
import { Submission, TestRun } from './types'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'

export const ResultsPanel = ({
  submission,
  timeout,
  onUpdate,
  onSubmit,
  isSubmitDisabled,
}: {
  submission: Submission | undefined
  timeout: number
  onUpdate: (testRun: TestRun) => void
  onSubmit: () => void
  isSubmitDisabled: boolean
}) => (
  <Tab.Panel id="results" context={TabsContext}>
    <section className="results">
      {submission && submission.testRun && (
        <TestRunSummary
          testRun={submission.testRun}
          cancelLink={submission.links.cancel}
          timeout={timeout}
          onUpdate={onUpdate}
          onSubmit={onSubmit}
          isSubmitDisabled={isSubmitDisabled}
        />
      )}
    </section>
  </Tab.Panel>
)
