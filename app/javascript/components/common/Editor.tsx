import React, { useEffect, useState } from 'react'
import consumer from '../../utils/action-cable-consumer'

type Submission = {
  status: SubmissionStatus
  tests: TestResult[]
}

enum SubmissionStatus {
  PASS = 'pass',
}

type TestResult = {
  name: string
  status: TestResultStatus
  output: string
}

enum TestResultStatus {
  PASS = 'pass',
}

export function Editor({ solutionId }: { solutionId: string }) {
  const [submission, setSubmission] = useState<Submission>()
  const [subscription, setSubscription] = useState(
    consumer.subscriptions.create(
      { channel: 'Test::SolutionsChannel', id: solutionId },
      {
        received: (submission: Submission) => {
          setSubmission(submission)
        },
      }
    )
  )
  const [code, setCode] = useState('')

  useEffect(() => {
    return () => {
      subscription.unsubscribe()
    }
  }, [])

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()

    subscription.perform('submit', { code: code })
  }

  function handleChange(e: React.ChangeEvent<HTMLTextAreaElement>) {
    setCode(e.target.value)
  }

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <label htmlFor="code">Code</label>
        <textarea onChange={handleChange} id="code"></textarea>
        <button>Submit</button>
      </form>
      {submission && <p>Status: {submission.status}</p>}
      {submission &&
        submission.tests.map((result) => (
          <p>
            name: {result.name}, status: {result.status}, output:{' '}
            {result.output}
          </p>
        ))}
    </div>
  )
}
