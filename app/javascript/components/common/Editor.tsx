import React, { useState } from 'react'
import { CodeEditor } from './Editor/CodeEditor'
import { TestRuns } from './Editor/TestRuns'
import fetch from 'isomorphic-fetch'

export type Submission = {
  id: number
  testsStatus: SubmissionTestsStatus
  testRuns: TestRun[]
  message: string
}

export enum SubmissionTestsStatus {
  PASS = 'pass',
  FAIL = 'fail',
  ERROR = 'error',
  PENDING = 'pending',
  OPS_ERROR = 'ops_error',
}

type TestRun = {
  name: string
  status: TestRunStatus
  output: string
}

enum TestRunStatus {
  PASS = 'pass',
}

export function Editor({ endpoint }: { endpoint: string }) {
  const [submission, setSubmission] = useState<Submission>()

  function submit(code: string) {
    setSubmission(undefined)

    fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ code: code }),
    })
      .then((response) => response.json())
      .then((json) =>
        setSubmission({
          id: json.id,
          testsStatus: json.tests_status,
          testRuns: json.test_runs,
          message: json.message,
        })
      )
  }

  return (
    <div>
      <CodeEditor onSubmit={submit} />
      {submission && <TestRuns submission={submission} />}
    </div>
  )
}
