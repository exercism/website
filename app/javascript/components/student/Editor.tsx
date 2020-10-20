import React, { useState } from 'react'
import { CodeEditor } from './editor/CodeEditor'
import { TestRunSummary } from './editor/TestRunSummary'
import { fetchJSON } from '../../utils/fetch-json'
import { typecheck } from '../../utils/typecheck'

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

    fetchJSON(endpoint, {
      method: 'POST',
      body: JSON.stringify({ files: { file: code } }),
    }).then((json: any) => {
      setSubmission(typecheck<Submission>(json, 'submission'))
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
