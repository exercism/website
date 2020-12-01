import React from 'react'
import { TestRunSummary } from './TestRunSummary'
import { Submission, TestRun } from './types'

export const ResultsPanel = ({
  submission,
  timeout,
  onUpdate,
}: {
  submission: Submission | undefined
  timeout: number
  onUpdate: (testRun: TestRun) => void
}) => (
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
)
