import React, { useState, useEffect } from 'react'
import { Submission, SubmissionTestsStatus } from '../Editor'
import consumer from '../../../utils/action-cable-consumer'

function Content({ submission }: { submission: Submission }) {
  switch (submission.testsStatus) {
    case SubmissionTestsStatus.PASS:
    case SubmissionTestsStatus.FAIL:
      return (
        <>
          {submission.testRuns.map((run) => (
            <p key={run.name}>
              name: {run.name}, status: {run.status}, output: {run.output}
            </p>
          ))}
        </>
      )
    case SubmissionTestsStatus.ERROR:
    case SubmissionTestsStatus.OPS_ERROR:
      return <p>{submission.message}</p>
    default:
      return <></>
  }
}

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

  return (
    <div>
      <p>Status: {submission.testsStatus}</p>
      <Content submission={submission} />
    </div>
  )
}
