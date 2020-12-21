import React from 'react'
import { TestRunSummary } from './TestRunSummary'
import { Submission, TestRun } from './types'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'

export const ResultsPanel = ({
  submission,
  timeout,
  onUpdate,
}: {
  submission: Submission | undefined
  timeout: number
  onUpdate: (testRun: TestRun) => void
}) => (
  <Tab.Panel index="results" context={TabsContext}>
    <section className="results">
      {submission && submission.testRun && (
        <TestRunSummary
          testRun={submission.testRun}
          cancelLink={submission.links.cancel}
          timeout={timeout}
          onUpdate={onUpdate}
        />
      )}
    </section>
  </Tab.Panel>
)
