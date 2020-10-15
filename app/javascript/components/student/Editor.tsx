import React, { useState } from 'react'
import { CodeEditor } from './editor/CodeEditor'
import { TestRunSummary } from './editor/TestRunSummary'
import fetch from 'isomorphic-fetch'

export type Submission = {
  testsStatus: TestRunStatus
  uuid: string
}

export enum TestRunStatus {
  PASS = 'pass',
  FAIL = 'fail',
  ERROR = 'error',
  PENDING = 'pending',
  OPS_ERROR = 'ops_error',
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
        setSubmission({ testsStatus: json.tests_status, uuid: json.uuid })
      )
  }

  return (
    <div>
      <CodeEditor onSubmit={submit} />
      {submission && <TestRunSummary submission={submission} />}
    </div>
  )
}
