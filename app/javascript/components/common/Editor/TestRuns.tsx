import React, { useState, useEffect } from 'react'
import { Submission } from '../Editor'
import consumer from '../../../utils/action-cable-consumer'

export function TestRuns({ submission }: { submission: Submission }) {
  const [testsStatus, setTestsStatus] = useState(submission.testsStatus)
  const [testRuns, setTestRuns] = useState(submission.testRuns)

  useEffect(() => {
    const subscription = consumer.subscriptions.create(
      { channel: 'Test::Submissions::TestRunsChannel', id: submission.id },
      {
        received: (submission: any) => {
          setTestsStatus(submission.tests_status)
          setTestRuns(submission.test_runs)
        },
      }
    )

    return () => {
      subscription.unsubscribe()
    }
  }, [submission.id])

  return (
    <div>
      <p>Status: {testsStatus}</p>
      {testRuns.map((run) => (
        <p>
          name: {run.name}, status: {run.status}, output: {run.output}
        </p>
      ))}
    </div>
  )
}
