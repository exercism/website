import React from 'react'
import { TestRunSummary } from './TestRunSummary'
import { Submission, TestRun } from './types'
import { Tab } from './Tab'
import { TabIndex } from '../Editor'

export const ResultsPanel = ({
  submission,
  timeout,
  onUpdate,
}: {
  submission: Submission | undefined
  timeout: number
  onUpdate: (testRun: TestRun) => void
}) => (
  <Tab.Panel index={TabIndex.RESULTS}>
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
