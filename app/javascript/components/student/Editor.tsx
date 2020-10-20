import React, { useState } from 'react'
import { CodeEditor } from './editor/CodeEditor'
import { TestRunSummary } from './editor/TestRunSummary'

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

export function Editor({
  endpoint,
  timeout = 60000,
}: {
  endpoint: string
  timeout?: number
}) {
  const [submission, setSubmission] = useState<Submission>()

  function submit(code: string) {
    setSubmission(undefined)

    fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ files: { file: code } }),
    })
      .then((response) => response.json())
      .then(({ submission }: any) => {
        setSubmission({
          testsStatus: submission.tests_status,
          uuid: submission.uuid,
        })
      })
  }

  return (
    <div>
      <CodeEditor onSubmit={submit} />
      {submission && (
        <TestRunSummary submission={submission} timeout={timeout} />
      )}
    </div>
  )
}
