import React, { useReducer, useRef, useEffect, useCallback } from 'react'
import { CodeEditor } from './editor/CodeEditor'
import { TestRunSummary } from './editor/TestRunSummary'
import { Submitting } from './editor/Submitting'
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

export enum EditorStatus {
  SUBMITTING = 'submitting',
  SUBMITTED = 'submitted',
  SUBMISSION_CANCELLED = 'submissionCancelled',
}

type State = {
  submission?: Submission
  code: string
  status?: EditorStatus
}

export type Action =
  | { type: EditorStatus.SUBMITTING; payload: { code: string } }
  | { type: EditorStatus.SUBMITTED; payload: { submission: Submission } }
  | { type: EditorStatus.SUBMISSION_CANCELLED }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case EditorStatus.SUBMITTING:
      return {
        ...state,
        status: EditorStatus.SUBMITTING,
        submission: undefined,
        code: action.payload.code,
      }
    case EditorStatus.SUBMITTED:
      return {
        ...state,
        status: EditorStatus.SUBMITTED,
        submission: action.payload.submission,
      }
    case EditorStatus.SUBMISSION_CANCELLED:
      return {
        ...state,
        status: EditorStatus.SUBMISSION_CANCELLED,
      }
    default:
      return state
  }
}

export function Editor({
  endpoint,
  timeout = 60000,
}: {
  endpoint: string
  timeout?: number
}) {
  const [{ submission, code, status }, dispatch] = useReducer(reducer, {
    status: undefined,
    submission: undefined,
    code: '',
  })
  const controllerRef = useRef(new AbortController())
  const abortFetch = useCallback(() => {
    controllerRef.current.abort()
    controllerRef.current = new AbortController()
  }, [controllerRef.current])

  useEffect(() => {
    return () => {
      abortFetch()
    }
  }, [])

  useEffect(() => {
    switch (status) {
      case EditorStatus.SUBMITTED:
      case EditorStatus.SUBMISSION_CANCELLED:
        abortFetch()
        break
      case EditorStatus.SUBMITTING:
        abortFetch()

        fetchJSON(endpoint, {
          method: 'POST',
          signal: controllerRef.current.signal,
          body: JSON.stringify({ files: { file: code } }),
        })
          .then((json: any) => {
            dispatch({
              type: EditorStatus.SUBMITTED,
              payload: {
                submission: typecheck<Submission>(json, 'submission'),
              },
            })
          })
          .catch((responseOrError) => {
            if (responseOrError.name === 'AbortError') {
              console.log('Fetch cancelled')
            }
          })
        break
    }
  })

  return (
    <div>
      <CodeEditor dispatch={dispatch} />
      {status === EditorStatus.SUBMITTING && <Submitting dispatch={dispatch} />}
      {submission && (
        <TestRunSummary submission={submission} timeout={timeout} />
      )}
    </div>
  )
}
