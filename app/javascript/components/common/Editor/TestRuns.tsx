import React, { useState, useEffect } from 'react'
import { Submission, SubmissionTestsStatus } from '../Editor'
import consumer from '../../../utils/action-cable-consumer'

export function TestRuns(props: { submission: Submission }) {
  const [submission, setSubmission] = useState(props.submission)

  useEffect(() => {
    const subscription = consumer.subscriptions.create(
      { channel: 'Test::Submissions::TestRunsChannel', id: submission.id },
      {
        received: (json: any) => {
          setSubmission({
            id: submission.id,
            testsStatus: json.tests_status,
            testRuns: json.test_runs,
            message: json.message,
          })
        },
      }
    )

    return () => {
      subscription.unsubscribe()
    }
  }, [submission.id])

  let content

  switch (submission.testsStatus) {
    case SubmissionTestsStatus.PASS: {
      content = submission.testRuns.map((run) => (
        <p key={run.name}>
          name: {run.name}, status: {run.status}, output: {run.output}
        </p>
      ))
    }
    case SubmissionTestsStatus.FAIL: {
      content = submission.testRuns.map((run) => (
        <p key={run.name}>
          name: {run.name}, status: {run.status}, output: {run.output}
        </p>
      ))
    }
    case SubmissionTestsStatus.ERROR: {
      content = <p>{submission.message}</p>
    }
  }

  return (
    <div>
      <p>Status: {submission.testsStatus}</p>
      {content}
    </div>
  )
}
